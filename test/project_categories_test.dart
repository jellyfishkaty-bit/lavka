import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:lavka/features/projects/project.dart';
import 'package:lavka/features/workshop_scene/gallery2_desk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('eight explicit categories map to approved desk artwork', () {
    expect(categoryIconIds.length, 8);
    for (final entry in categoryIconIds.entries) {
      expect(projectCategories, contains(entry.key));
      expect(iconIdForCategory(entry.key), entry.value);
      expect(Gallery2Item.fromIconId(entry.value), isNotNull);
    }
    for (final category in ['Одежда', 'Аксессуар', 'Для дома', 'Другое', 'unknown']) {
      final fallback = iconIdForCategory(category);
      expect(fallback, 'yarn');
      expect(Gallery2Item.fromIconId(fallback), isNull);
    }
  });

  test('new category projects and legacy icons retain independent counters', () async {
    final repo = await WorkshopRepository.open(
      factory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    try {
      final legacy = await repo.createProject(title: 'Старый', category: 'Одежда',
          craftType: 'needles', iconId: 'socks', palette: 0);
      final ids = <int>[];
      for (final entry in categoryIconIds.entries) {
        ids.add(await repo.createProject(title: entry.key, category: entry.key,
            craftType: 'needles', iconId: iconIdForCategory(entry.key), palette: 0));
      }
      final snapshot = await repo.load();
      for (final entry in categoryIconIds.entries) {
        final item = snapshot.projects.singleWhere((p) => p.title == entry.key);
        expect(item.iconId, entry.value);
      }
      await repo.changeRow(legacy, 1);
      await repo.changeRow(ids.last, 1);
      await repo.changeRow(ids.last, 1);
      await repo.undo(ids.last);
      await repo.selectProject(legacy);
      final current = await repo.load();
      expect(current.active!.category, 'Одежда');
      expect(current.active!.iconId, 'socks');
      expect(current.active!.currentRow, 1);
      expect(current.projects.singleWhere((p) => p.id == ids.last).currentRow, 1);
    } finally {
      await repo.close();
    }
  });
}
