import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:lavka/app/workshop_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory dir;
  late WorkshopRepository repo;
  late DateTime now;
  Future<int> create([String title = 'Миссони', String icon = 'stole']) =>
      repo.createProject(
        title: title,
        category: 'Палантин',
        craftType: 'needles',
        iconId: icon,
        palette: 1,
      );
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lavka-test-');
    now = DateTime(2026, 11, 10, 23, 59);
    repo = await WorkshopRepository.open(
      factory: databaseFactoryFfi,
      databasePath: '${dir.path}/test.sqlite',
      clock: () => now,
    );
  });
  tearDown(() async {
    await repo.close();
    await dir.delete(recursive: true);
  });

  test('15 additions, 2 unravels, reopen retains row 13 and icon', () async {
    final id = await create();
    for (var i = 0; i < 15; i++) {
      await repo.changeRow(id, 1);
    }
    for (var i = 0; i < 2; i++) {
      await repo.changeRow(id, -1);
    }
    await repo.close();
    repo = await WorkshopRepository.open(
      factory: databaseFactoryFfi,
      databasePath: '${dir.path}/test.sqlite',
      clock: () => now,
    );
    final s = await repo.load();
    expect(s.active!.currentRow, 13);
    expect(s.active!.iconId, 'stole');
    expect(s.active!.palette, 1);
    expect(s.total, 15);
    expect(s.today, 15);
  });
  test('two projects never share counters; selection persists', () async {
    final first = await create();
    final second = await create('Шаль', 'shawl');
    await repo.changeRow(first, 1);
    await repo.changeRow(second, 1);
    await repo.changeRow(second, 1);
    await repo.selectProject(first);
    final s = await repo.load();
    expect(s.active!.id, first);
    expect(s.active!.currentRow, 1);
    expect(s.projects.firstWhere((p) => p.id == second).currentRow, 2);
    expect(s.projects.map((p) => p.iconId).toSet().length, 2);
  });
  test('cannot go below zero; zero decrement adds no event', () async {
    final id = await create();
    await repo.changeRow(id, -1);
    expect((await repo.load()).active!.currentRow, 0);
    expect(await repo.db.query('row_events'), isEmpty);
  });
  test('undo is persisted, reverses credit on original date', () async {
    final id = await create();
    await repo.changeRow(id, 1);
    now = now.add(const Duration(minutes: 2));
    expect((await repo.load()).today, 0);
    await repo.undo(id);
    final s = await repo.load();
    expect(s.total, 0);
    expect(s.today, 0);
    expect(s.active!.currentRow, 0);
    expect(s.canUndo, false);
    await repo.undo(id);
    expect((await repo.db.query('row_events')).length, 2);
  });
  test('undo unravelling restores row without creating credit', () async {
    final id = await create();
    await repo.changeRow(id, 1);
    await repo.changeRow(id, -1);
    await repo.undo(id);
    expect((await repo.load()).active!.currentRow, 1);
    expect((await repo.load()).total, 1);
    await repo.undo(id);
    expect((await repo.load()).total, 0);
  });
  test('transaction rollback never leaves half of a counter action', () async {
    final id = await create();
    await repo.db.execute(
      '''CREATE TRIGGER reject_update BEFORE UPDATE ON counters
      BEGIN SELECT RAISE(ABORT, 'simulated disk error'); END''',
    );
    await expectLater(repo.changeRow(id, 1), throwsA(isA<DatabaseException>()));
    expect(await repo.db.query('row_events'), isEmpty);
    expect((await repo.load()).active!.currentRow, 0);
  });
  test('controller queues 40 rapid taps captured before switching', () async {
    final a = await create('А');
    final b = await create('Б', 'hat');
    await repo.selectProject(a);
    final c = WorkshopController(repo);
    await c.refresh();
    final actions = [for (var i = 0; i < 40; i++) c.row(a, 1)];
    actions.add(c.select(b));
    expect((await Future.wait(actions)).every((ok) => ok), true);
    expect(c.snapshot!.active!.id, b);
    expect(c.snapshot!.active!.currentRow, 0);
    expect(c.snapshot!.projects.firstWhere((p) => p.id == a).currentRow, 40);
    expect(c.pending, 0);
    c.dispose();
  });
  test('failed command recovers and later commands still execute', () async {
    final id = await create();
    final c = WorkshopController(repo);
    await c.refresh();
    expect(await c.row(id, 2), false);
    expect(c.snapshot!.active!.currentRow, 0);
    expect(c.error, isNotNull);
    expect(await c.row(id, 1), true);
    expect(c.error, isNull);
    c.dispose();
  });
  test('preferences survive reopening', () async {
    await repo.preferences(reducedMotion: true, haptics: false);
    await repo.close();
    repo = await WorkshopRepository.open(
      factory: databaseFactoryFfi,
      databasePath: '${dir.path}/test.sqlite',
    );
    expect((await repo.load()).reducedMotion, true);
    expect((await repo.load()).haptics, false);
  });
  test('invalid form data never creates partial projects', () async {
    await expectLater(create('  '), throwsArgumentError);
    expect((await repo.load()).projects, isEmpty);
  });
}
