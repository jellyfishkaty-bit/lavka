// Staging-only Gallery #2 layout based on owner-approved mockups.
// Do not modify production Flutter scenes or replace legacy art.
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'trial.dart';

enum Gallery2Item {
  sweater('sweater.png', Rect.fromLTWH(149.14783, 181.54792, 105.73913, 71.19962)),
  socks('socks.png', Rect.fromLTWH(156.93913, 187.11039, 93.49565, 67.86214)),
  blanket('blanket.png', Rect.fromLTWH(144.69565, 197.12283, 110.1913, 58.96218)),
  toy('toy.png', Rect.fromLTWH(155.82609, 174.87295, 130.22609, 84.54955)),
  shawl('shawl.png', Rect.fromLTWH(145.8087, 206.02278, 135.7913, 64.52465)),
  scarf('scarf.png', Rect.fromLTWH(154.71304, 199.34782, 111.30435, 76.76209)),
  fabric('fabric.png', Rect.fromLTWH(143.58261, 210.47276, 134.67826, 75.6496)),
  stole('stole.png', Rect.fromLTWH(143.58261, 199.34782, 131.33913, 87.88703));
  const Gallery2Item(this.assetFile, this.baseSceneRect);
  final String assetFile;
  final Rect baseSceneRect;
}

class Gallery2Room extends TrialRoom {
  Gallery2Room({required this.item}) : super(variant: null);

  final Gallery2Item item;
  SpriteComponent? gallerySprite;

  void positionGallerySprite() {
    final component = gallerySprite;
    if (component == null) return;
    final scene = item.baseSceneRect.shift(Offset(0, geometry.shift('desk')));
    component.position = Vector2(scene.left, scene.top);
    component.size = Vector2(scene.width, scene.height);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    positionGallerySprite();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await loadSprite('gallery2/${item.assetFile}');
    final component = SpriteComponent(
      sprite: sprite,
      priority: 33,
      paint: Paint()..filterQuality = FilterQuality.none..isAntiAlias = false,
    );
    gallerySprite = component;
    await world.add(component);
    positionGallerySprite();
  }
}
