import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'scene_layout.dart';
import 'gallery2_desk.dart';

/// Presentation only. No SQL, project state, rewards or network access.
/// Outdoor view, architecture, furniture, lighting and effects are independent.
class WorkshopGame extends FlameGame {
  WorkshopGame({this.harborAsset = 'harbor_dusk.png'});
  final String harborAsset;
  // Independent presentation of owner-approved artwork, never stored in SQLite.
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
  RoomViewport layout = RoomViewport(const Size(384, 432));
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
    for (final effect in world.children.whereType<_LampLight>()) {
      effect.position.y = layout.shift('lamp');
    }
    for (final effect in world.children.whereType<_Steam>()) {
      effect.position.y = layout.shift('mug');
    }
    for (final sprite in world.children.whereType<RoomSprite>()) {
      sprite.position.y = layout.objectBounds(sprite.definition).top;
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
    // Each sprite is independently replaceable and independently placed.
    for (final object in roomObjects) {
      await world.add(
        RoomSprite(object, await loadSprite('workshop_v2/${object.asset}'))
          ..position.y = layout.objectBounds(object).top,
      );
    }
    await world.add(
      _Floor(await loadSprite('workshop_v2/floor_tile.png'), () => layout)
        ..priority = 1,
    );
    await world.add(
      _Harbor(await loadSprite('workshop_v2/$harborAsset'))..priority = 10,
    );
    // Preserve approved Gallery #2 textures exactly. Desk z=32, artwork z=33.
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
    await world.add(_Rain(() => elapsed)..priority = 15);
    await world.add(
      _LampLight(() => elapsed)
        ..position.y = layout.shift('lamp')
        ..priority = 37,
    );
    await world.add(
      _Steam(() => elapsed)
        ..position.y = layout.shift('mug')
        ..priority = 42,
    );
  }

  @override
  void update(double dt) {
    if (!reducedMotion && active) elapsed = (elapsed + dt) % 120;
    super.update(dt);
    // Let the first update mount loaded objects before any pause.
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

class _Harbor extends Component {
  _Harbor(this.sprite);
  final Sprite sprite;
  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.clipPath(windowOpeningPath(), doAntiAlias: false);
    sprite.renderRect(
      canvas,
      windowGlass,
      overridePaint: Paint()..filterQuality = FilterQuality.none,
    );
    canvas.restore();
  }
}

class _Rain extends Component {
  _Rain(this.clock);
  final double Function() clock;
  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.clipPath(windowOpeningPath(), doAntiAlias: false);
    final paint = Paint()
      ..color = const Color(0x779fbcd2)
      ..isAntiAlias = false;
    for (var i = 0; i < 53; i++) {
      final x = windowGlass.left + ((i * 37) % 153);
      final y = windowGlass.top + ((i * 47 + clock() * 43) % 170).floor();
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 3 + (i % 4).toDouble()), paint);
    }
    canvas.restore();
  }
}

class _LampLight extends PositionComponent {
  _LampLight(this.clock);
  final double Function() clock;
  @override
  void render(Canvas canvas) {
    final strength = .8 + .04 * math.sin(clock() * 1.3);
    for (var i = 6; i >= 0; i--) {
      final radius = 16.0 + i * 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(167, 208),
            width: radius * 2,
            height: radius * 1.6,
          ),
          const Radius.circular(18),
        ),
        Paint()
          ..isAntiAlias = false
          ..color = Color.fromRGBO(255, 181, 79, .018 * strength),
      );
    }
    // Pool of warm lamplight on the tabletop is its own lighting layer.
    canvas.drawRect(
      const Rect.fromLTWH(133, 242, 102, 2),
      Paint()
        ..color = const Color(0x44ffd795)
        ..isAntiAlias = false,
    );
  }
}

class _Steam extends PositionComponent {
  _Steam(this.clock);
  final double Function() clock;
  @override
  void render(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final phase = (clock() * .32 + i / 3) % 1;
      final y = (226 - phase * 20).floorToDouble();
      final x = (254 + math.sin(phase * 6 + i) * 3).floorToDouble();
      final p = Paint()
        ..isAntiAlias = false
        ..color = Color.fromRGBO(245, 222, 185, (1 - phase) * .48);
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 4), p);
      canvas.drawRect(Rect.fromLTWH(x + 1, y - 2, 1, 2), p);
    }
  }
}

/// Repeat the existing floor texture; foreground sprites retain their proportions.
class _Floor extends Component {
  _Floor(this.sprite, this.layout);
  final Sprite sprite;
  final RoomViewport Function() layout;
  @override
  void render(Canvas canvas) {
    final room = layout();
    final top = 307 + (room.height - 432) * .8;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, top, 384, room.height - top));
    for (double y = top; y < room.height; y += 64) {
      for (double x = 0; x < 384; x += 64) {
        sprite.renderRect(
          canvas,
          Rect.fromLTWH(x, y, 64, 64),
          overridePaint: Paint()..filterQuality = FilterQuality.none,
        );
      }
    }
    canvas.restore();
  }
}
