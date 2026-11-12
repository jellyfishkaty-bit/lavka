import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/projects/project.dart';

/// Owns all durable state. Scene and widgets never write directly to SQLite.
class WorkshopRepository {
  WorkshopRepository(this.db, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final Database db;
  final DateTime Function() clock;

  static Future<WorkshopRepository> open({
    DatabaseFactory? factory,
    String? databasePath,
    DateTime Function()? clock,
  }) async {
    final f = factory ?? databaseFactory;
    final file =
        databasePath ?? p.join(await f.getDatabasesPath(), 'lavka.sqlite');
    final schema = await rootBundle.loadString('assets/data/schema_v1.sql');
    final database = await f.openDatabase(
      file,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await db.rawQuery('PRAGMA journal_mode = WAL');
          await db.execute('PRAGMA synchronous = FULL');
        },
        onCreate: (db, version) async {
          for (final statement in schema.split(';')) {
            if (statement.trim().isNotEmpty) await db.execute(statement);
          }
        },
        // Unknown versions must fail closed; never delete user data to migrate.
        onUpgrade: (db, oldVersion, newVersion) async {
          throw StateError('Нет миграции $oldVersion → $newVersion');
        },
      ),
    );
    return WorkshopRepository(database, clock: clock);
  }

  String _day(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Future<WorkshopSnapshot> load() => db.transaction((tx) async {
    final settings = (await tx.query('settings')).single;
    final projects = await tx.rawQuery('''SELECT p.*, c.current_row
      FROM projects p JOIN counters c ON p.id = c.project_id
      ORDER BY p.created_at DESC, p.id DESC''');
    final activeId = settings['active_project_id'] as int?;
    final totals = (await tx.rawQuery(
      '''SELECT
      COALESCE(SUM(work_delta),0) AS total,
      COALESCE(SUM(CASE WHEN local_day=? THEN work_delta ELSE 0 END),0) AS today
      FROM row_events''',
      [_day(clock())],
    )).single;
    final undo = activeId == null
        ? <Map<String, Object?>>[]
        : await _undoable(tx, activeId);
    return WorkshopSnapshot(
      projects: List.unmodifiable(projects.map(Project.fromMap)),
      activeId: activeId,
      today: totals['today'] as int,
      total: totals['total'] as int,
      canUndo: undo.isNotEmpty,
      reducedMotion: settings['reduced_motion'] == 1,
      haptics: settings['haptics'] == 1,
    );
  });

  Future<int> createProject({
    required String title,
    required String category,
    required String craftType,
    required String iconId,
    required int palette,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty ||
        trimmed.length > 80 ||
        category.trim().isEmpty ||
        !(iconId == 'fabric' || projectIcons.any((i) => i.id == iconId)) ||
        palette < 0 ||
        palette > 3 ||
        !['needles', 'hook', 'other'].contains(craftType)) {
      throw ArgumentError('Проверьте поля проекта');
    }
    return db.transaction((tx) async {
      final timestamp = clock().toUtc().toIso8601String();
      final id = await tx.insert('projects', {
        'title': trimmed,
        'category': category,
        'craft_type': craftType,
        'icon_id': iconId,
        'palette': palette,
        'created_at': timestamp,
        'updated_at': timestamp,
      });
      await tx.insert('counters', {'project_id': id, 'updated_at': timestamp});
      await tx.update('settings', {'active_project_id': id}, where: 'id=1');
      return id;
    });
  }

  Future<void> selectProject(int id) => db.transaction((tx) async {
    if ((await tx.query('projects', where: 'id=?', whereArgs: [id])).isEmpty) {
      throw StateError('Проект не найден');
    }
    await tx.update('settings', {'active_project_id': id}, where: 'id=1');
  });

  Future<void> changeRow(int projectId, int delta) async {
    if (delta != 1 && delta != -1) throw ArgumentError.value(delta);
    await db.transaction((tx) async {
      final current =
          (await tx.query(
                'counters',
                where: 'project_id=?',
                whereArgs: [projectId],
              )).single['current_row']
              as int;
      if (current == 0 && delta == -1) return;
      final now = clock();
      final timestamp = now.toUtc().toIso8601String();
      await tx.insert('row_events', {
        'project_id': projectId,
        'timestamp_utc': timestamp,
        'local_day': _day(now),
        'delta': delta,
        'work_delta': delta == 1 ? 1 : 0,
        'before_row': current,
        'after_row': current + delta,
        'reason': delta == 1 ? 'knit' : 'unravel',
      });
      await _setRow(tx, projectId, current + delta, timestamp);
    });
  }

  Future<List<Map<String, Object?>>> _undoable(DatabaseExecutor tx, int id) =>
      tx.rawQuery(
        '''SELECT e.* FROM row_events e
      WHERE e.project_id=? AND e.reason != 'undo'
      AND NOT EXISTS(SELECT 1 FROM row_events u WHERE u.undo_of=e.id)
      ORDER BY e.id DESC LIMIT 1''',
        [id],
      );

  /// Correction reverses the original work credit on its original local day.
  /// Unravelling preserves work already done; rewards are a future subsystem.
  Future<void> undo(int projectId) => db.transaction((tx) async {
    final found = await _undoable(tx, projectId);
    if (found.isEmpty) return;
    final event = found.single;
    final current =
        (await tx.query(
              'counters',
              where: 'project_id=?',
              whereArgs: [projectId],
            )).single['current_row']
            as int;
    if (current != event['after_row'])
      throw StateError('Нарушен порядок журнала');
    final timestamp = clock().toUtc().toIso8601String();
    await tx.insert('row_events', {
      'project_id': projectId,
      'timestamp_utc': timestamp,
      'local_day': event['local_day'],
      'delta': -(event['delta'] as int),
      'work_delta': -(event['work_delta'] as int),
      'before_row': current,
      'after_row': event['before_row'],
      'reason': 'undo',
      'undo_of': event['id'],
    });
    await _setRow(tx, projectId, event['before_row'] as int, timestamp);
  });

  Future<void> _setRow(
    Transaction tx,
    int id,
    int row,
    String timestamp,
  ) async {
    await tx.update(
      'counters',
      {'current_row': row, 'updated_at': timestamp},
      where: 'project_id=?',
      whereArgs: [id],
    );
    await tx.update(
      'projects',
      {'updated_at': timestamp},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> preferences({bool? reducedMotion, bool? haptics}) async {
    await db.update('settings', {
      if (reducedMotion != null) 'reduced_motion': reducedMotion ? 1 : 0,
      if (haptics != null) 'haptics': haptics ? 1 : 0,
    }, where: 'id=1');
  }

  Future<void> close() => db.close();
}
