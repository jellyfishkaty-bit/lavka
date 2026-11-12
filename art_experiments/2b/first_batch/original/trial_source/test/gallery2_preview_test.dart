// Requires eight Gallery #2 RGBA textures. Until then this is a
// non-executable staging test, NOT evidence of a successful Flutter render.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_check/trial.dart';
import 'package:scene_check/gallery2_preview.dart';

void main() {
  for (final item in Gallery2Item.values) {
    testWidgets('Gallery2 ${item.name} in true Flutter room 393x493', (t) async {
      t.view.physicalSize = const Size(393, 493);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final game = Gallery2Room(item: item);
      final imageKey = GlobalKey();
      await t.pumpWidget(MaterialApp(home: RepaintBoundary(
        key: imageKey,
        child: TrialView(game: game, onTap: (_) {}),
      )));
      for (var i=0; i<120 && (!game.isLoaded || game.gallerySprite == null); i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await t.pump();
      }
      expect(game.isLoaded, isTrue);
      expect(game.gallerySprite, isNotNull);
      expect(game.gallerySprite!.size.x, greaterThan(0));
      expect(game.gallerySprite!.size.y, greaterThan(0));
      expect(game.gallerySprite!.sprite, isNotNull);
      await t.pump(const Duration(milliseconds: 80));
      await t.runAsync(() async {
        final boundary = imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final out = File('build/gallery2_renders/${item.name}_393_493.png');
        await out.parent.create(recursive: true);
        await out.writeAsBytes(bytes!.buffer.asUint8List());
        expect(await out.length(), greaterThan(100));
        image.dispose();
      });
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  }
}
