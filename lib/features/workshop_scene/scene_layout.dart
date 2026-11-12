import 'dart:math' as math;
import 'dart:ui';

/// Geometry is shared by Flame rendering and accessible Flutter hit targets.
/// Room width is 384; adaptive height is 368–500. Sprites keep their aspect ratios.
enum SceneRoute { currentProject, patterns, projects, mail, rewards }

class RoomObject {
  const RoomObject(this.id, this.asset, this.bounds, this.z);
  final String id, asset;
  final Rect bounds;
  final int z;
}

class RoomTarget {
  const RoomTarget(this.route, this.label, this.bounds, {this.sign});
  final SceneRoute route;
  final String label;
  final Rect bounds;
  final Rect? sign;
}

class RoomViewport {
  RoomViewport(Size viewport) {
    height = (viewport.height / viewport.width * 384).clamp(368.0, 500.0);
    scale = math.min(viewport.width / roomSize.width, viewport.height / height);
    offset = Offset(
      (viewport.width - roomSize.width * scale) / 2,
      (viewport.height - height * scale) / 2,
    );
  }
  late final double height;
  late final double scale;
  double shift(String id) => switch (id) {
    'rug' || 'basket' || 'chest' || 'cat' => height - 432,
    'chair' || 'desk' || 'lamp' || 'mug' => (height - 432) * .6,
    _ => 0,
  };
  Rect objectBounds(RoomObject object) =>
      object.bounds.shift(Offset(0, shift(object.id)));
  Rect targetBounds(RoomTarget target, {bool sign = false}) {
    final id = switch (target.route) {
      SceneRoute.currentProject => 'desk',
      SceneRoute.projects => 'basket',
      SceneRoute.rewards => 'chest',
      _ => '',
    };
    return (sign ? target.sign! : target.bounds).shift(Offset(0, shift(id)));
  }

  late final Offset offset;
  Rect project(Rect scene) => Rect.fromLTWH(
    offset.dx + scene.left * scale,
    offset.dy + scene.top * scale,
    scene.width * scale,
    scene.height * scale,
  );

  /// Inflate around the object's center, then keep the whole target on canvas.
  Rect target(Rect scene, Size viewport) {
    final rect = project(scene);
    final width = math.min(viewport.width, math.max(48.0, rect.width));
    final height = math.min(viewport.height, math.max(48.0, rect.height));
    return Rect.fromLTWH(
      (rect.center.dx - width / 2).clamp(0, viewport.width - width),
      (rect.center.dy - height / 2).clamp(0, viewport.height - height),
      width,
      height,
    );
  }
}

const roomSize = Size(384, 432);
const windowGlass = Rect.fromLTWH(23, 31, 153, 170);
Path windowOpeningPath() => Path()
  ..moveTo(windowGlass.left, windowGlass.bottom)
  ..lineTo(windowGlass.right, windowGlass.bottom)
  ..lineTo(windowGlass.right, windowGlass.top + 34)
  ..quadraticBezierTo(
    windowGlass.right - 20,
    windowGlass.top,
    windowGlass.center.dx,
    windowGlass.top,
  )
  ..quadraticBezierTo(
    windowGlass.left + 20,
    windowGlass.top,
    windowGlass.left,
    windowGlass.top + 34,
  )
  ..close();

// Gallery #2 approved backdrop, directly matching the pilot trial.dart.
const roomObjects = <RoomObject>[
  RoomObject('walls', 'walls_floor_revision.png', Rect.fromLTWH(0, 0, 384, 480), 0),
  RoomObject('harbor', 'harbor_masked.png', Rect.fromLTWH(5, 8, 176, 220), 10),
  RoomObject('window', 'window.png', Rect.fromLTWH(5, 8, 176, 220), 20),
  RoomObject('bookcase', 'bookcase_revision.png', Rect.fromLTWH(151, 10, 247, 309), 22),
  RoomObject('rug', 'rug_2a.png', Rect.fromLTWH(12, 329, 360, 101.17), 25),
  RoomObject('chair', 'chair.png', Rect.fromLTWH(0, 210, 125, 151), 30),
  RoomObject('desk', 'desk_revision.png', Rect.fromLTWH(97, 215, 240, 120), 32),
  RoomObject('basket', 'basket_2a.png', Rect.fromLTWH(117, 315, 70, 87.1), 45),
  RoomObject('chest', 'chest_2a.png', Rect.fromLTWH(266, 326, 109, 85.26), 46),
  RoomObject('cat', 'cat_2a.png', Rect.fromLTWH(25, 363, 104, 67.91), 48),
];

const roomTargets = <RoomTarget>[
  RoomTarget(
    SceneRoute.patterns,
    'Книжный шкаф — узоры',
    Rect.fromLTWH(202, 30, 101, 150),
    sign: Rect.fromLTWH(222, 121, 107, 28),
  ),
  RoomTarget(
    SceneRoute.mail,
    'Почтовый ящик — письма',
    Rect.fromLTWH(329, 165, 51, 80),
    sign: Rect.fromLTWH(302, 240, 80, 28),
  ),
  RoomTarget(
    SceneRoute.currentProject,
    'Рабочий стол — текущий проект',
    Rect.fromLTWH(109, 216, 185, 105),
  ),
  RoomTarget(
    SceneRoute.projects,
    'Корзина с пряжей — проекты',
    Rect.fromLTWH(114, 341, 73, 69),
  ),
  RoomTarget(
    SceneRoute.rewards,
    'Сундук — награды',
    Rect.fromLTWH(275, 330, 106, 84),
    sign: Rect.fromLTWH(274, 396, 108, 28),
  ),
];
