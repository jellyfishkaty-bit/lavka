import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavka/app/theme.dart';
import 'package:lavka/app/pixel_widgets.dart';
import 'package:lavka/app/workshop_app.dart';
import 'package:lavka/app/workshop_controller.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  testWidgets(
    'header counts status inset once and navigation preserves all labels',
    (t) async {
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 32, bottom: 24);
      t.view.viewPadding = const FakeViewPadding(top: 32, bottom: 24);
      addTearDown(t.view.reset);
      for (final scale in [1.0, 1.3, 1.5]) {
        t.platformDispatcher.textScaleFactorTestValue = scale;
        await t.pumpWidget(
          MaterialApp(
            theme: workshopTheme(),
            home: Scaffold(
              appBar: const WorkshopHeader(
                title: 'Лавка забытых историй',
                subtitle: 'Гавань · дождливый вечер',
              ),
              bottomNavigationBar: WorkshopNavigation(
                index: 0,
                onSelect: (_) {},
              ),
              body: const SizedBox.expand(),
            ),
          ),
        );
        expect(t.getSize(find.byType(AppBar)).height, 96);
        for (final text in ['Лавка', 'Вяжем', 'Узоры', 'Проекты']) {
          expect(find.text(text).hitTestable(), findsOneWidget);
        }
        expect(t.takeException(), isNull);
      }
      t.platformDispatcher.clearTextScaleFactorTestValue();
    },
  );
  for (final scenario in ['empty', 'no-active', 'large-counter']) {
    testWidgets('320dp 150% text: $scenario remains usable', (t) async {
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 32, bottom: 24);
      t.view.viewPadding = const FakeViewPadding(top: 32, bottom: 24);
      t.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      late WorkshopRepository repo;
      late WorkshopController c;
      await t.runAsync(() async {
        repo = await WorkshopRepository.open(
          factory: databaseFactoryFfiNoIsolate,
          databasePath: inMemoryDatabasePath,
        );
        await repo.preferences(reducedMotion: true, haptics: false);
        if (scenario != 'empty') {
          final id = await repo.createProject(
            title: 'Ёжик, шаль и палантин с очень длинным русским названием',
            category: 'Палантин',
            craftType: 'needles',
            iconId: 'stole',
            palette: 0,
          );
          if (scenario == 'no-active') {
            await repo.db.update('settings', {'active_project_id': null});
          }
          if (scenario == 'large-counter') {
            await repo.db.update(
              'counters',
              {'current_row': 9223372036854775806},
              where: 'project_id = ?',
              whereArgs: [id],
            );
          }
        }
        c = WorkshopController(repo);
      });
      Future<void> settle() async {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 120)),
        );
        await t.pump();
        await t.pump(const Duration(milliseconds: 900));
      }

      try {
        await t.pumpWidget(WorkshopApp(controller: c));
        await settle();
        await t.tap(find.text('Вяжем').last);
        await settle();
        expect(t.takeException(), isNull);
        if (scenario == 'large-counter') {
          expect(find.text('Ряд 9223372036854775806'), findsOneWidget);
        } else {
          expect(find.text('Создать проект').hitTestable(), findsOneWidget);
        }
        await t.pumpWidget(const SizedBox());
        await settle();
      } finally {
        c.dispose();
        await repo.close();
      }
    });
  }
}
