import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lavka/app/workshop_app.dart';
import 'package:lavka/app/workshop_controller.dart';
import 'package:lavka/app/pixel_widgets.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:lavka/features/workshop_scene/scene_layout.dart';
import 'package:lavka/features/workshop_scene/workshop_scene_view.dart';
import 'package:lavka/features/workshop_scene/workshop_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test(
    'v0.1.1 file opens with counters, icons, settings and journal intact',
    () async {
      final dir = await Directory.systemTemp.createTemp('lavka-upgrade-');
      final file = await File('test/fixtures/lavka_v011.sqlite')
          .copy('${dir.path}/lavka.sqlite');
      final repo = await WorkshopRepository.open(
        factory: databaseFactoryFfi,
        databasePath: file.path,
        clock: () => DateTime(2026, 11, 10, 12),
      );
      try {
        final s = await repo.load();
        expect(s.projects.length, 2);
        expect(s.activeId, 7);
        expect(s.active!.currentRow, 13);
        expect(s.active!.iconId, 'stole');
        expect(s.active!.palette, 2);
        expect(s.total, 15);
        expect(s.today, 15);
        expect(s.reducedMotion, true);
        expect(s.haptics, false);
        await repo.changeRow(7, 1);
        expect((await repo.load()).active!.currentRow, 14);
        await repo.undo(7);
        expect((await repo.load()).active!.currentRow, 13);
        expect(
          (await repo.db.rawQuery('PRAGMA user_version')).single.values.single,
          1,
        );
        expect((await repo.db.query('row_events')).length, 19);
      } finally {
        await repo.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test(
    'logical hit targets map inside viewports and stay at least 48 pixels',
    () {
      for (final size in [
        const Size(320, 200),
        const Size(360, 340),
        const Size(390, 432),
        const Size(430, 500),
        const Size(600, 650),
      ]) {
        final viewport = RoomViewport(size);
        for (final target in roomTargets) {
          final rect = viewport.target(viewport.targetBounds(target), size);
          expect(rect.width, greaterThanOrEqualTo(48 - 1e-6));
          expect(rect.height, greaterThanOrEqualTo(48 - 1e-6));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
          expect(
            rect.contains(
              viewport.project(viewport.targetBounds(target)).center,
            ),
            true,
          );
        }
      }
    },
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  Future<void> loadFonts() async {
    final body = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-400.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-500.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-600.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-700.ttf'));
    await body.load();
    await (FontLoader('Handjet')
          ..addFont(rootBundle.load('assets/fonts/Handjet-500.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Handjet-600.ttf')))
        .load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  }

  Future<void> capture(GlobalKey key, String name) async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/screenshots/v021')..createSync(recursive: true);
    await File('${dir.path}/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  }

  for (final size in [
    const Size(320, 640),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
    const Size(600, 960),
  ]) {
    testWidgets(
      'scene routes and counter stay usable at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        late WorkshopRepository repo;
        late WorkshopController controller;
        await tester.runAsync(() async {
          repo = await WorkshopRepository.open(
            factory: databaseFactoryFfiNoIsolate,
            databasePath: inMemoryDatabasePath,
          );
          await repo.preferences(reducedMotion: true, haptics: false);
          await repo.createProject(
            title: 'Палантин «Миссони»',
            category: 'Палантин',
            craftType: 'needles',
            iconId: 'stole',
            palette: 2,
          );
          controller = WorkshopController(repo);
        });
        try {
          final key = GlobalKey();
          await tester.runAsync(loadFonts);
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: WorkshopApp(controller: controller),
            ),
          );
          await settle(tester);
          final scene = tester.widget<WorkshopSceneView>(
            find.byType(WorkshopSceneView),
          );
          for (
            var attempt = 0;
            attempt < 40 &&
                (!scene.game.isLoaded ||
                    scene.game.world.children.whereType<RoomSprite>().length <
                        roomObjects.length);
            attempt++
          ) {
            await settle(tester);
          }
          expect(
            scene.game.isLoaded,
            true,
            reason: 'Flame assets must complete loading',
          );
          await tester.pump();
          await tester.pump();
          expect(
            scene.game.world.children.whereType<RoomSprite>().length,
            roomObjects.length,
          );
          for (final target in roomTargets) {
            final finder = find
                .byKey(ValueKey('room-${target.route.name}'))
                .hitTestable();
            expect(finder, findsOneWidget);
            final box = tester.getSize(finder);
            expect(box.width, greaterThanOrEqualTo(48 - 1e-6));
            expect(box.height, greaterThanOrEqualTo(48 - 1e-6));
          }
          final add = find.byKey(const ValueKey('add-row')).hitTestable();
          expect(add, findsOneWidget);
          expect(
            tester.getBottomRight(add).dy,
            lessThan(tester.getTopLeft(find.byType(WorkshopNavigation)).dy),
          );
          await tester.tap(add);
          await settle(tester);
          expect(controller.snapshot!.active!.currentRow, 1);
          await tester.runAsync(
            () => capture(
              key,
              'shop-${size.width.toInt()}x${size.height.toInt()}',
            ),
          );
          // Tap the actual mapped object center, rather than only testing callbacks.
          await tester.tap(find.byKey(const ValueKey('room-patterns')));
          await settle(tester);
          expect(find.text('Книга узоров').hitTestable(), findsOneWidget);
          if (size.width == 390)
            await tester.runAsync(() => capture(key, 'patterns'));
          await tester.tap(find.text('Лавка').last);
          await settle(tester);
          await tester.tap(find.byKey(const ValueKey('room-currentProject')));
          await settle(tester);
          expect(find.text('Ряд 1').hitTestable(), findsOneWidget);
          if (size.width == 390)
            await tester.runAsync(() => capture(key, 'counter'));
          await tester.tap(find.text('Лавка').last);
          await settle(tester);
          await tester.tap(find.byKey(const ValueKey('room-projects')));
          await settle(tester);
          expect(find.text('Новый проект').hitTestable(), findsOneWidget);
          if (size.width == 390)
            await tester.runAsync(() => capture(key, 'projects'));
          await tester.tap(find.text('Лавка').last);
          await settle(tester);
          for (final route in [SceneRoute.mail, SceneRoute.rewards]) {
            await tester.tap(find.byKey(ValueKey('room-${route.name}')));
            await settle(tester);
            expect(find.text('Будущий раздел').hitTestable(), findsOneWidget);
            expect(scene.game.paused, true);
            if (size.width == 390)
              await tester.runAsync(() => capture(key, route.name));
            await tester.tap(find.byType(BackButton).hitTestable());
            await settle(tester);
          }
          expect(controller.snapshot!.active!.currentRow, 1);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await settle(tester);
        } finally {
          controller.dispose();
          await repo.close();
        }
      },
    );
  }
}
