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
    // The original desk PNG is 1774 x 887. At this horizontal position its
    // visible tabletop starts at source y=49: 49 / 887 * 120 = 6.63 room units.
    // Place the top of the stole just inside it; the rest hangs in front.
    final desk = room.sprites['desk']!;
    component.position = Vector2(198, desk.position.y + 8);
    component.size = Vector2(41, 62); // Half-size, original 82:124 aspect.
    expect(desk.size.x, 240);
    expect(desk.size.y, 120);
    expect(component.position.x, greaterThanOrEqualTo(desk.position.x));
    expect(component.position.x + component.size.x,
        lessThanOrEqualTo(desk.position.x + desk.size.x));
    expect(component.position.y, greaterThanOrEqualTo(desk.position.y + 6.63));
    expect(component.position.y, lessThan(desk.position.y + 30));
    expect(component.position.y + component.size.y,
        lessThanOrEqualTo(desk.position.y + 75));
    expect(component.priority, greaterThan(desk.priority));
    expect(component.size.x / component.size.y, closeTo(82 / 124, 0.00001));
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
