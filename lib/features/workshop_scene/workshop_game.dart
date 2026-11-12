import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'scene_layout.dart';
import 'gallery2_desk.dart';

/// Real application scene. Uses exactly the validated Gallery #2 pilot room
/// sprites (not the decorative v0.2 workshop_v2 desk with a baked-in stole).
/// The saved projects and SQLite remain independent of the scene.
class WorkshopGame extends FlameGame {
  WorkshopGame({this.harborAsset = 'harbor_masked.png'});
  final String harborAsset;

  RoomViewport layout = RoomViewport(const Size(384, 432));

  final Map<Gallery2Item, Sprite> _approvedArtwork = {};
  SpriteComponent? activeDeskArtwork;
  String? _selectedProjectIcon;

  void selectProjectIcon(String? iconId) {
    if (_selectedProjectIcon == iconId) return;
    _selectedProjectIcon = iconId;
    _positionDeskArtwork();
  }

  void _positionDeskArtwork() {
    final component = activeDeskArtwork;
    if (component == null) return;
    final item = Gallery2Item.fromIconId(_selectedProjectIcon);
    if (item == null) {
      component.size = Vector2.zero();
      return;
    }
    final rect = item.approvedSceneRect.shift(Offset(0, layout.shift('desk')));
    component.sprite = _approvedArtwork[item];
    component.position = Vector2(rect.left, rect.top);
    component.size = Vector2(rect.width, rect.height);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0 || size.y <= 0) return;
    layout = RoomViewport(Size(size.x, size.y));
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.zoom = layout.scale;
    camera.viewfinder.position = Vector2(
      -layout.offset.dx / layout.scale,
      -layout.offset.dy / layout.scale,
    );
    for (final sprite in world.children.whereType<RoomSprite>()) {
      final rect = layout.objectBounds(sprite.definition);
      sprite.position.y = rect.top;
      if (sprite.definition.id == 'walls') {
        sprite.size.y = math.max(480.0, layout.height);
      }
    }
    _positionDeskArtwork();
  }

  double elapsed = 0;
  bool reducedMotion = false;
  bool active = true;
  bool _updated = false;

  void presentation({required bool active, required bool reducedMotion}) {
    this.active = active;
    this.reducedMotion = reducedMotion;
    if (active) {
      resumeEngine();
    } else if (_updated) {
      pauseEngine();
    }
  }

  @override
  Color backgroundColor() => const Color(0xff38272a);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    onGameResize(size);
    // Exact source bytes, positions and priorities from the approved trial.
    for (final object in roomObjects) {
      final file = object.id == 'harbor' ? harborAsset : object.asset;
      final component = RoomSprite(
        object,
        await loadSprite('workshop_gallery2/$file'),
      )..position.y = layout.objectBounds(object).top;
      if (object.id == 'walls') {
        component.size.y = math.max(480.0, layout.height);
      }
      await world.add(component);
    }

    // One actively selected item, above the bare desk (priority 32).
    for (final item in Gallery2Item.values) {
      _approvedArtwork[item] = await loadSprite('gallery2/${item.assetFile}');
    }
    activeDeskArtwork = SpriteComponent(
      sprite: _approvedArtwork[Gallery2Item.sweater],
      size: Vector2.zero(),
      priority: 33,
      paint: Paint()
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false,
    );
    await world.add(activeDeskArtwork!);
    _positionDeskArtwork();
  }

  @override
  void update(double dt) {
    if (!reducedMotion && active) elapsed = (elapsed + dt) % 120;
    super.update(dt);
    _updated = true;
    if (!active) pauseEngine();
  }
}

class RoomSprite extends SpriteComponent {
  RoomSprite(this.definition, Sprite image)
      : super(
          sprite: image,
          position: Vector2(definition.bounds.left, definition.bounds.top),
          size: Vector2(definition.bounds.width, definition.bounds.height),
          priority: definition.z,
          paint: Paint()
            ..filterQuality = FilterQuality.none
            ..isAntiAlias = false,
        );
  final RoomObject definition;
}
