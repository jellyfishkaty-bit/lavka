import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavka/features/workshop_scene/gallery2_desk.dart';
import 'package:lavka/features/workshop_scene/scene_layout.dart';
import 'package:lavka/features/workshop_scene/workshop_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exact icon mapping for eight artworks without inferring other categories', () {
    expect(Gallery2Item.values.length, 8);
    for (final item in Gallery2Item.values) {
      expect(Gallery2Item.fromIconId(item.id), item);
      expect(item.approvedSceneRect.width, greaterThan(0));
      expect(item.approvedSceneRect.height, greaterThan(0));
    }
    expect(Gallery2Item.fromIconId('hat'), isNull);
    expect(Gallery2Item.fromIconId(null), isNull);
  });

  testWidgets('production Flame scene renders all eight approved objects', (t) async {
    Flame.images.prefix = 'assets/images/';
    t.view.physicalSize = const Size(393, 493);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final game = WorkshopGame();
    final key = GlobalKey();
    game.selectProjectIcon('sweater');
    await t.pumpWidget(MaterialApp(
      home: RepaintBoundary(key: key, child: GameWidget(game: game)),
    ));
    for (var attempt = 0; attempt < 120 &&
        (!game.isLoaded || game.activeDeskArtwork == null); attempt++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await t.pump();
    }
    expect(game.isLoaded, isTrue);
    expect(game.activeDeskArtwork, isNotNull);
    final viewport = RoomViewport(const Size(393, 493));
    for (final item in Gallery2Item.values) {
      game.selectProjectIcon(item.id);
      await t.pump(const Duration(milliseconds: 80));
      final sprite = game.activeDeskArtwork!;
      final expected = item.approvedSceneRect.shift(
        Offset(0, viewport.shift('desk')),
      );
      expect(sprite.sprite, isNotNull);
      expect(sprite.size.x, closeTo(expected.width, .01));
      expect(sprite.size.y, closeTo(expected.height, .01));
      expect(sprite.position.x, closeTo(expected.left, .01));
      expect(sprite.position.y, closeTo(expected.top, .01));
      await t.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
        final png = await boundary.toImage(pixelRatio: 3);
        final bytes = await png.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/gallery2_app_renders/${item.id}_393_493.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        png.dispose();
        expect(await file.length(), greaterThan(100));
      });
    }
    game.selectProjectIcon('hat');
    await t.pump();
    expect(game.activeDeskArtwork!.size.x, 0);
    game.selectProjectIcon(null);
    await t.pump();
    expect(game.activeDeskArtwork!.size.x, 0);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
