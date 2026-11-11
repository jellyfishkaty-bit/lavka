import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_check/projects_on_desk.dart';
import 'package:scene_check/trial.dart';

void main() {
  testWidgets('isolated native stole prototype at 393 x 493', (tester) async {
    tester.view.physicalSize = const Size(393, 493);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final room = TrialRoom();
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: key,
        child: TrialView(game: room, onTap: (_) {}),
      ),
    ));
    for (var i = 0; i < 60 && (!room.isLoaded ||
        room.world.children.whereType<PositionComponent>().length < 10); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    expect(room.isLoaded, isTrue);
    final bytes = File('../../../native_grid/stole_native_82x124.png')
        .readAsBytesSync();
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    });
    expect(image, isNotNull);
    expect(image!.width, 82);
    expect(image.height, 124);
    room.projectSprites[KnittingVariant.stole] = Sprite(image);
    room.selectVariant(KnittingVariant.stole);
    final component = room.projectSprite!;
    component.position = Vector2(198, 281 - 124 + room.geometry.shift('desk'));
    component.size = Vector2(82, 124);
    expect(component.paint.filterQuality, FilterQuality.none);
    await tester.pump(const Duration(milliseconds: 30));
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final frame = await boundary.toImage(pixelRatio: 3);
      final data = await frame.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/test_renders').create(recursive: true);
      await File('build/test_renders/stole_prototype_393_493.png')
          .writeAsBytes(data!.buffer.asUint8List());
      frame.dispose();
    });
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    image.dispose();
  });
}
