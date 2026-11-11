import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'project.dart';

class PixelIcon extends StatelessWidget {
  const PixelIcon({
    super.key,
    required this.icon,
    required this.palette,
    this.size = 56,
  });
  final ProjectIcon icon;
  final int palette;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: icon.label,
    image: true,
    child: Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size < 48 ? 3 : 7),
      decoration: BoxDecoration(
        color: iconBackdrops[palette],
        border: Border.all(color: gold, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(
        icon.asset,
        filterQuality: FilterQuality.none,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
  );
}
