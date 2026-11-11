// Runs against the real sqflite Android plugin, never the user's main DB.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:lavka/app/workshop_app.dart';
import 'package:lavka/app/workshop_controller.dart';
import 'package:lavka/core/storage/workshop_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native SQLite survives close/reopen with independent counters', (
    tester,
  ) async {
    final file = p.join(
      await getDatabasesPath(),
      'lavka-integration-only.sqlite',
    );
    await deleteDatabase(file);
    var repo = await WorkshopRepository.open(databasePath: file);
    await repo.preferences(reducedMotion: true);
    final a = await repo.createProject(
      title: 'Палантин',
      category: 'Палантин',
      craftType: 'needles',
      iconId: 'stole',
      palette: 1,
    );
    final b = await repo.createProject(
      title: 'Шаль',
      category: 'Шаль',
      craftType: 'hook',
      iconId: 'shawl',
      palette: 2,
    );
    await repo.selectProject(a);
    var controller = WorkshopController(repo);
    await tester.pumpWidget(WorkshopApp(controller: controller));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.text('Вяжем').last);
    await tester.pump();
    for (var i = 0; i < 15; i++) {
      await tester.tap(find.byKey(const ValueKey('add-row')).hitTestable());
    }
    await controller.run(() async {});
    await controller.row(a, -1);
    await controller.row(a, -1);
    expect(controller.snapshot!.active!.currentRow, 13);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    await repo.close();
    repo = await WorkshopRepository.open(databasePath: file);
    controller = WorkshopController(repo);
    await controller.refresh();
    expect(controller.snapshot!.active!.currentRow, 13);
    expect(
      controller.snapshot!.projects.firstWhere((p) => p.id == b).currentRow,
      0,
    );
    expect(controller.snapshot!.active!.iconId, 'stole');
    controller.dispose();
    await repo.close();
    await deleteDatabase(file);
  });
}
