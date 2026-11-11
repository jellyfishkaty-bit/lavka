import 'dart:io';
import 'dart:convert';

import 'package:lavka/app/theme.dart';

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
import 'package:lavka/features/workshop_scene/workshop_scene_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  Future<void> settle(WidgetTester t) async {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 900));
  }

  Future<void> fonts() async {
    for (final family in ['Montserrat', 'Handjet']) {
      final paths = Directory('assets/fonts')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('$family-') && f.path.endsWith('.ttf'));
      if (paths.isNotEmpty) {
        final loader = FontLoader(family);
        for (final f in paths) {
          loader.addFont(rootBundle.load(f.path));
        }
        await loader.load();
      } else if (family == 'Montserrat') {
        await (FontLoader(
          family,
        )..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'))).load();
      }
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  }

  Future<void> capture(GlobalKey key, String name) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: name.endsWith('text1.0') ? 3 : 1,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/screenshots/mobile')
      ..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
    image.dispose();
  }

  for (final size in [
    const Size(320, 640),
    const Size(360, 800),
    const Size(393, 852),
    const Size(430, 932),
    const Size(480, 800),
  ]) {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('Android insets $size text $scale all screens', (t) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        t.view.padding = const FakeViewPadding(top: 32, bottom: 24);
        t.view.viewPadding = const FakeViewPadding(top: 32, bottom: 24);
        t.platformDispatcher.textScaleFactorTestValue = scale;
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
          await repo.createProject(
            title: scale == 1
                ? 'Палантин «Миссони»'
                : 'Очень длинный палантин «Ёлочка» для любимой мамы',
            category: 'Палантин',
            craftType: 'needles',
            iconId: 'stole',
            palette: 2,
          );
          c = WorkshopController(repo);
          await fonts();
        });
        final key = GlobalKey();
        try {
          await t.pumpWidget(
            RepaintBoundary(
              key: key,
              child: WorkshopApp(controller: c),
            ),
          );
          await settle(t);
          final scene = t.widget<WorkshopSceneView>(
            find.byType(WorkshopSceneView),
          );
          for (var i = 0; i < 40 && !scene.game.isLoaded; i++) {
            await settle(t);
          }
          expect(scene.game.isLoaded, true);
          for (final screen in ['shop', 'counter', 'patterns', 'projects']) {
            final tab = [
              'shop',
              'counter',
              'patterns',
              'projects',
            ].indexOf(screen);
            if (tab > 0) {
              await t.tap(
                find.text(['Лавка', 'Вяжем', 'Узоры', 'Проекты'][tab]).last,
              );
              await settle(t);
            }
            expect(t.takeException(), isNull, reason: '$size $scale $screen');
            final nav = t.getRect(find.byType(WorkshopNavigation));
            expect(nav.bottom, lessThanOrEqualTo(size.height));
            if (tab < 2) {
              final add = find.byKey(const ValueKey('add-row'));
              await t.ensureVisible(add);
              await settle(t);
              expect(t.getSize(add).height, greaterThanOrEqualTo(48));
              await t.tap(add);
              await settle(t);
              expect(c.snapshot!.active!.currentRow, tab + 1);
            }
            if ((size.width == 320 || size.width == 393)) {
              if (tab == 0 && scale == 1) {
                final sceneSize = t.getSize(find.byType(WorkshopSceneView));
                final appBar = t.getSize(find.byType(AppBar));
                final file = File(
                  'docs/screenshots/mobile/metrics-${size.width.toInt()}.txt',
                );
                file.writeAsStringSync(
                  'scene: $sceneSize\nheader: $appBar\nnav: ${nav.size}\n',
                );
              }

              if (scale == 1) {
                List<double> coords(Rect r) => [
                  r.left,
                  r.top,
                  r.right,
                  r.bottom,
                ];
                final data = <String, Object>{
                  'pixelRatio': 3,
                  'screen': screen,
                  'header': coords(t.getRect(find.byType(WorkshopHeader))),
                };
                if (tab == 0) {
                  for (final route in ['patterns', 'mail', 'rewards']) {
                    data[route] = coords(
                      t.getRect(find.byKey(ValueKey('sign-frame-$route'))),
                    );
                  }
                }
                if (tab == 2)
                  data['decorativeTitle'] = coords(
                    t.getRect(find.text('Книга узоров')),
                  );
                final dir = Directory('docs/screenshots/v022')
                  ..createSync(recursive: true);
                File('${dir.path}/$screen-${size.width.toInt()}-bounds.json')
                    .writeAsStringSync(jsonEncode(data));
              }
              await t.runAsync(
                () => capture(
                  key,
                  '$screen-${size.width.toInt()}x${size.height.toInt()}-text$scale',
                ),
              );
            }
            expect(t.takeException(), isNull);
          }
          await t.pumpWidget(const SizedBox());
          await settle(t);
        } finally {
          c.dispose();
          await repo.close();
        }
      });
    }
  }
}
