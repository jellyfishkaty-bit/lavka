import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavka/app/theme.dart';
import 'package:lavka/features/workshop_scene/scene_layout.dart';
import 'package:lavka/features/workshop_scene/scene_sign.dart';
import 'package:lavka/features/workshop_scene/workshop_scene_view.dart';

Future<void> loadPatchFonts() async {
  for (final family in ['Montserrat', 'Handjet']) {
    final loader = FontLoader(family);
    for (final w
        in family == 'Montserrat' ? [400, 500, 600, 700] : [500, 600]) {
      loader.addFont(rootBundle.load('assets/fonts/$family-$w.ttf'));
    }
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final viewport in [
    const Size(320, 307),
    const Size(393, 493),
    const Size(480, 460),
  ]) {
    testWidgets('painted plaque text stays clear of frame at $viewport', (
      t,
    ) async {
      await t.runAsync(loadPatchFonts);
      for (final dpr in [1.0, 2.0, 2.75]) {
        t.view.physicalSize = viewport * dpr;
        t.view.devicePixelRatio = dpr;
        for (final scale in [1.0, 1.3, 1.5]) {
          t.platformDispatcher.textScaleFactorTestValue = scale;
          final view = RoomViewport(viewport);
          final targets = roomTargets.where((v) => v.sign != null).toList();
          var tapped = 0;
          await t.pumpWidget(
            MaterialApp(
              theme: workshopTheme(),
              home: Scaffold(
                body: Stack(
                  children: [
                    for (final target in targets)
                      Builder(
                        builder: (context) {
                          final label = WorkshopSceneView.signText(
                            target.route,
                          );
                          final place = SceneSignPlacement.measure(
                            view: view,
                            target: target,
                            viewport: viewport,
                            label: label,
                            scaler: MediaQuery.textScalerOf(context),
                            direction: TextDirection.ltr,
                          );
                          return Positioned.fromRect(
                            rect: place.hit,
                            child: SceneSign(
                              target: target,
                              label: label,
                              placement: place,
                              onTap: () => tapped++,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
          await t.pump();
          for (final target in targets) {
            final text = find.byKey(ValueKey('sign-text-${target.route.name}'));
            final frame = find.byKey(
              ValueKey('sign-frame-${target.route.name}'),
            );
            final bounds = t.getRect(frame), textRect = t.getRect(text);
            expect(textRect.left - bounds.left, greaterThanOrEqualTo(13.9));
            expect(bounds.right - textRect.right, greaterThanOrEqualTo(13.9));
            expect(textRect.top - bounds.top, greaterThanOrEqualTo(9.9));
            expect(bounds.bottom - textRect.bottom, greaterThanOrEqualTo(9.9));
            final paragraph = t.renderObject<RenderParagraph>(
              find.descendant(of: text, matching: find.byType(RichText)),
            );
            for (final box in paragraph.getBoxesForSelection(
              TextSelection(
                baseOffset: 0,
                extentOffset: WorkshopSceneView.signText(target.route).length,
              ),
            )) {
              final rect = box.toRect().shift(textRect.topLeft);
              expect(bounds.deflate(9).contains(rect.topLeft), true);
              expect(bounds.deflate(9).contains(rect.bottomRight), true);
            }
            expect(paragraph.didExceedMaxLines, false);
            expect(bounds.left, greaterThanOrEqualTo(3.9));
            expect(bounds.right, lessThanOrEqualTo(viewport.width - 3.9));
            expect(bounds.bottom, lessThanOrEqualTo(viewport.height - 3.9));
            final hit = find.byKey(ValueKey('sign-hit-${target.route.name}'));
            expect(t.getSize(hit).shortestSide, greaterThanOrEqualTo(48));
            await t.tap(hit);
          }
          expect(tapped, 3);
          expect(t.takeException(), isNull);
        }
      }
      addTearDown(t.view.reset);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    });
  }
  testWidgets(
    'all toolbar titles are readable and fully fit at standard mobile text size',
    (t) async {
      await t.runAsync(loadPatchFonts);
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      for (final title in [
        'Лавка забытых историй',
        'Вяжем',
        'Узоры',
        'Проекты',
      ]) {
        await t.pumpWidget(
          MaterialApp(
            theme: workshopTheme(),
            home: Scaffold(
              appBar: WorkshopHeader(
                title: title,
                subtitle: title.startsWith('Лавка')
                    ? 'Гавань · дождливый вечер'
                    : null,
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        );
        final text = t.widget<Text>(find.text(title));
        expect(text.style!.fontFamily, 'Montserrat');
        final paragraph = t.renderObject<RenderParagraph>(
          find.descendant(
            of: find.text(title),
            matching: find.byType(RichText),
          ),
        );
        expect(paragraph.didExceedMaxLines, false, reason: title);
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets('capture decorative heading and standalone plaques at 3x', (
    t,
  ) async {
    await t.runAsync(loadPatchFonts);
    t.view.physicalSize = const Size(393, 600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final key = GlobalKey();
    await t.pumpWidget(
      MaterialApp(
        theme: workshopTheme(),
        home: RepaintBoundary(
          key: key,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Книга узоров',
                    style: WorkshopType.sectionTitle.copyWith(color: cream),
                  ),
                  const SizedBox(height: 20),
                  for (final target in roomTargets.where((v) => v.sign != null))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: 180,
                        height: 64,
                        child: SceneSign(
                          target: target,
                          label: WorkshopSceneView.signText(target.route),
                          placement: SceneSignPlacement.measure(
                            view: RoomViewport(const Size(393, 493)),
                            target: target,
                            viewport: const Size(393, 493),
                            label: WorkshopSceneView.signText(target.route),
                            scaler: TextScaler.noScaling,
                            direction: TextDirection.ltr,
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await t.pump();
    await t.runAsync(() async {
      final img =
          await (key.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 3);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/screenshots/v022')
        ..createSync(recursive: true);
      File('${dir.path}/font-detail-3x.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
      img.dispose();
    });
    expect(t.takeException(), isNull);
  });
}
