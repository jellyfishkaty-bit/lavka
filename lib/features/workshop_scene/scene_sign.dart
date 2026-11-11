import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/pixel_widgets.dart';
import '../../app/theme.dart';
import 'scene_layout.dart';

/// Plaques are Flutter text, not pixels baked into furniture sprites.
/// Measure in screen dp AFTER the room transform; never squash the text.
class SceneSignPlacement {
  const SceneSignPlacement(this.plaque, this.hit);
  final Rect plaque;
  final Rect hit;
  static const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  static SceneSignPlacement measure({
    required RoomViewport view,
    required RoomTarget target,
    required Size viewport,
    required String label,
    required TextScaler scaler,
    required TextDirection direction,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: WorkshopType.sceneLabel),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble() + padding.horizontal;
    final height = painter.height.ceilToDouble() + padding.vertical;
    painter.dispose();
    final anchor = view
        .target(view.targetBounds(target, sign: true), viewport)
        .center;
    final plaque = Rect.fromLTWH(
      (anchor.dx - width / 2).clamp(
        4.0,
        math.max(4.0, viewport.width - width - 4),
      ),
      (anchor.dy - height / 2).clamp(
        4.0,
        math.max(4.0, viewport.height - height - 4),
      ),
      width,
      height,
    );
    final hitWidth = math.max(48.0, width), hitHeight = math.max(48.0, height);
    final hit = Rect.fromLTWH(
      (plaque.center.dx - hitWidth / 2).clamp(
        0.0,
        math.max(0.0, viewport.width - hitWidth),
      ),
      (plaque.center.dy - hitHeight / 2).clamp(
        0.0,
        math.max(0.0, viewport.height - hitHeight),
      ),
      hitWidth,
      hitHeight,
    );
    return SceneSignPlacement(plaque, hit);
  }
}

class SceneSign extends StatelessWidget {
  const SceneSign({
    super.key,
    required this.target,
    required this.label,
    required this.placement,
    required this.onTap,
  });
  final RoomTarget target;
  final String label;
  final SceneSignPlacement placement;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: target.label,
    child: Tooltip(
      message: target.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: ValueKey('sign-hit-${target.route.name}'),
          onTap: onTap,
          child: Center(
            child: SizedBox.fromSize(
              size: placement.plaque.size,
              child: PixelFrame(
                key: ValueKey('sign-frame-${target.route.name}'),
                fill: const Color(0xff4b2d2d),
                padding: SceneSignPlacement.padding,
                child: Text(
                  label,
                  key: ValueKey('sign-text-${target.route.name}'),
                  style: WorkshopType.sceneLabel,
                  textAlign: TextAlign.center,
                  textWidthBasis: TextWidthBasis.longestLine,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
