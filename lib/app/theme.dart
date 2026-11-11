import 'package:flutter/material.dart';

const ink = Color(0xff332329);
const cream = Color(0xfff2d8ac);
const gold = Color(0xffce9c60);
const wine = Color(0xff71374c);
const iconBackdrops = [
  Color(0xffeed0a1),
  Color(0xffaac6bd),
  Color(0xffd6a3ad),
  Color(0xffaab9d0),
];

/// Local fonts, real registered weights; all sizes follow Android TextScaler.
abstract final class WorkshopType {
  static const sectionTitle = TextStyle(
    fontFamily: 'Handjet',
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: .4,
  );
  static const toolbarTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );
  static const shopTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );
  static const largeButton = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.05,
  );
  static const sceneLabel = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
    color: cream,
  );
  static const projectTitle = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static const counterValue = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const navigationLabel = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: cream,
  );
  static const bodyText = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const secondary = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const buttonText = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );
  static const rowValue = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
}

/// AppBar owns the status inset. Route bodies must not add it a second time.
class WorkshopHeader extends StatelessWidget implements PreferredSizeWidget {
  const WorkshopHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 64);
  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: preferredSize.height,
    titleSpacing: 16,
    title: Tooltip(
      message: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subtitle == null
                ? WorkshopType.toolbarTitle
                : WorkshopType.shopTitle,
          ),
          if (subtitle != null &&
              MediaQuery.textScalerOf(context).scale(14) <= 18.2)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WorkshopType.secondary.copyWith(color: cream),
            ),
        ],
      ),
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: Divider(height: 1, thickness: 1, color: gold),
    ),
  );
}

ThemeData workshopTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Montserrat',
  textTheme: const TextTheme(
    bodyMedium: WorkshopType.bodyText,
    bodyLarge: WorkshopType.bodyText,
    bodySmall: WorkshopType.secondary,
    titleLarge: WorkshopType.sectionTitle,
    titleMedium: WorkshopType.projectTitle,
    labelLarge: WorkshopType.buttonText,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: wine,
    surface: cream,
    onSurface: ink,
    primary: wine,
    onPrimary: cream,
  ),
  scaffoldBackgroundColor: const Color(0xff35252b),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff35252b),
    foregroundColor: cream,
    centerTitle: false,
    toolbarHeight: 56,
    titleTextStyle: WorkshopType.toolbarTitle,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xff432c30),
    indicatorColor: wine,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(color: cream, fontSize: 12),
    ),
    iconTheme: WidgetStatePropertyAll(IconThemeData(color: cream)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: gold, width: 2),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      foregroundColor: ink,
      side: const BorderSide(color: Color(0xff986044), width: 2),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xffffe7c2),
    border: OutlineInputBorder(),
  ),
);

class Paper extends StatelessWidget {
  const Paper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _PaperOrnaments(),
    child: Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cream,
        border: Border.all(color: gold, width: 3),
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(color: Color(0xff211a20), offset: Offset(0, 4)),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}

class _PaperOrnaments extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x88996840)
      ..isAntiAlias = false;
    for (final corner in [
      Offset(6, 6),
      Offset(size.width - 6, 6),
      Offset(6, size.height - 6),
      Offset(size.width - 6, size.height - 6),
    ]) {
      final dx = corner.dx < size.width / 2 ? 1.0 : -1.0;
      final dy = corner.dy < size.height / 2 ? 1.0 : -1.0;
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: 3, height: 3),
        paint,
      );
      canvas.drawLine(
        corner,
        corner + Offset(8 * dx, 0),
        paint..strokeWidth = 1,
      );
      canvas.drawLine(corner, corner + Offset(0, 8 * dy), paint);
    }
  }

  @override
  bool shouldRepaint(_PaperOrnaments old) => false;
}
