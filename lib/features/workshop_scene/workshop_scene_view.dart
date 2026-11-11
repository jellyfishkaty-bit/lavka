import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'scene_layout.dart';
import 'scene_sign.dart';
import 'workshop_game.dart';

class WorkshopSceneView extends StatelessWidget {
  const WorkshopSceneView({
    super.key,
    required this.game,
    required this.onRoute,
  });
  final WorkshopGame game;
  final ValueChanged<SceneRoute> onRoute;
  static String signText(SceneRoute route) => switch (route) {
    SceneRoute.patterns => 'Узоры',
    SceneRoute.mail => 'Письма',
    SceneRoute.rewards => 'Награды',
    _ => '',
  };
  Widget _sign(
    BuildContext context,
    RoomViewport view,
    RoomTarget target,
    Size size,
  ) {
    final label = signText(target.route);
    final placement = SceneSignPlacement.measure(
      view: view,
      target: target,
      viewport: size,
      label: label,
      scaler: MediaQuery.textScalerOf(context),
      direction: Directionality.of(context),
    );
    return Positioned.fromRect(
      rect: placement.hit,
      child: SceneSign(
        target: target,
        label: label,
        placement: placement,
        onTap: () => onRoute(target.route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final size = Size(box.maxWidth, box.maxHeight);
      final view = RoomViewport(size);
      return ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: GameWidget(
                  game: game,
                  autofocus: false,
                  errorBuilder: (context, error) => const Center(
                    child: Text(
                      'Не удалось загрузить интерьер. Счётчик доступен во вкладке «Вяжем».',
                      style: TextStyle(color: cream),
                    ),
                  ),
                ),
              ),
            ),
            for (final target in roomTargets)
              Positioned.fromRect(
                rect: view.target(view.targetBounds(target), size),
                child: Semantics(
                  button: true,
                  label: target.label,
                  child: Tooltip(
                    message: target.label,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        key: ValueKey('room-${target.route.name}'),
                        onTap: () => onRoute(target.route),
                        splashColor: gold.withValues(alpha: .2),
                        highlightColor: gold.withValues(alpha: .12),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            for (final target in roomTargets.where((t) => t.sign != null))
              _sign(context, view, target, size),
          ],
        ),
      );
    },
  );
}
