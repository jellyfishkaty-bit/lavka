import 'package:flutter/material.dart';

import 'theme.dart';

enum PixelSymbol { shop, yarn, pattern, folder, mail, chest, settings, swap }

class PixelGlyph extends StatelessWidget {
  const PixelGlyph(
    this.symbol, {
    super.key,
    this.size = 28,
    this.color = cream,
  });
  final PixelSymbol symbol;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _GlyphPainter(symbol, color),
  );
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.symbol, this.color);
  final PixelSymbol symbol;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final p = Paint()
      ..color = color
      ..isAntiAlias = false;
    void r(double x, double y, double w, double h) =>
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    void line(List<Offset> points) {
      final path = Path()..addPolygon(points, false);
      canvas.drawPath(
        path,
        p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      p.style = PaintingStyle.fill;
    }

    switch (symbol) {
      case PixelSymbol.shop:
        r(4, 11, 2, 10);
        r(18, 11, 2, 10);
        r(4, 20, 16, 2);
        r(10, 15, 5, 6);
        r(4, 3, 16, 3);
        r(2, 6, 20, 3);
        for (var i = 0; i < 4; i++) r(2 + i * 5.0, 9, 3, 3);
      case PixelSymbol.yarn:
        for (var y = 4; y < 21; y++)
          for (var x = 3; x < 20; x++) {
            final dx = x - 11, dy = y - 12;
            if (dx * dx + dy * dy < 70 &&
                (dx * dx + dy * dy > 43 || (x + y) % 6 < 2))
              r(x.toDouble(), y.toDouble(), 1, 1);
          }
        line([const Offset(12, 12), const Offset(22, 2)]);
        r(21, 1, 2, 2);
      case PixelSymbol.pattern:
        for (var y = 4; y < 22; y += 6)
          line([
            Offset(2, y.toDouble() + 3),
            Offset(6, y.toDouble()),
            Offset(10, y.toDouble() + 3),
            Offset(14, y.toDouble()),
            Offset(18, y.toDouble() + 3),
            Offset(22, y.toDouble()),
          ]);
      case PixelSymbol.folder:
        line([
          const Offset(2, 20),
          const Offset(2, 5),
          const Offset(9, 5),
          const Offset(12, 8),
          const Offset(22, 8),
          const Offset(22, 20),
          const Offset(2, 20),
        ]);
        r(8, 12, 8, 2);
        r(6, 14, 2, 3);
        r(16, 14, 2, 3);
        r(8, 17, 8, 2);
      case PixelSymbol.mail:
        line([
          const Offset(2, 5),
          const Offset(22, 5),
          const Offset(22, 20),
          const Offset(2, 20),
          const Offset(2, 5),
        ]);
        line([const Offset(2, 6), const Offset(12, 14), const Offset(22, 6)]);
      case PixelSymbol.chest:
        line([
          const Offset(2, 10),
          const Offset(4, 5),
          const Offset(20, 5),
          const Offset(22, 10),
          const Offset(22, 21),
          const Offset(2, 21),
          const Offset(2, 10),
          const Offset(22, 10),
        ]);
        r(6, 5, 2, 16);
        r(16, 5, 2, 16);
        r(10, 9, 4, 6);
      case PixelSymbol.settings:
        for (var x in [3.0, 10.0, 17.0]) r(x, 3, 2, 18);
        r(1, 7, 6, 3);
        r(8, 15, 6, 3);
        r(15, 5, 6, 3);
      case PixelSymbol.swap:
        r(3, 6, 17, 2);
        r(4, 16, 17, 2);
        line([const Offset(15, 2), const Offset(20, 7), const Offset(15, 12)]);
        line([const Offset(9, 12), const Offset(4, 17), const Offset(9, 22)]);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.symbol != symbol || old.color != color;
}

class PixelFrame extends StatelessWidget {
  const PixelFrame({
    super.key,
    required this.child,
    this.fill = wine,
    this.bright = false,
    this.padding = const EdgeInsets.all(8),
  });
  final Widget child;
  final Color fill;
  final bool bright;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _FramePainter(fill, bright),
    child: Padding(padding: padding, child: child),
  );
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.fill, this.bright);
  final Color fill;
  final bool bright;
  @override
  void paint(Canvas c, Size s) {
    Path shape(double inset, double cut) => Path()
      ..moveTo(inset + cut, inset)
      ..lineTo(s.width - inset - cut, inset)
      ..lineTo(s.width - inset, inset + cut)
      ..lineTo(s.width - inset, s.height - inset - cut)
      ..lineTo(s.width - inset - cut, s.height - inset)
      ..lineTo(inset + cut, s.height - inset)
      ..lineTo(inset, s.height - inset - cut)
      ..lineTo(inset, inset + cut)
      ..close();
    c.drawPath(
      shape(0, 7),
      Paint()
        ..color = const Color(0xff291c25)
        ..isAntiAlias = false,
    );
    c.drawPath(
      shape(2, 6),
      Paint()
        ..color = bright ? const Color(0xfff6cd82) : gold
        ..isAntiAlias = false,
    );
    c.drawPath(
      shape(4, 5),
      Paint()
        ..color = const Color(0xff694431)
        ..isAntiAlias = false,
    );
    c.drawPath(
      shape(5, 4),
      Paint()
        ..color = fill
        ..isAntiAlias = false,
    );
    final p = Paint()
      ..color = gold
      ..isAntiAlias = false;
    for (final x in [8.0, s.width - 12])
      for (final y in [8.0, s.height - 12]) {
        c.drawRect(Rect.fromLTWH(x, y, 4, 1), p);
        c.drawRect(Rect.fromLTWH(x, y, 1, 4), p);
      }
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.fill != fill || old.bright != bright;
}

class WorkshopNavigation extends StatelessWidget {
  const WorkshopNavigation({
    super.key,
    required this.index,
    required this.onSelect,
  });
  final int index;
  final ValueChanged<int> onSelect;
  static const labels = ['Лавка', 'Вяжем', 'Узоры', 'Проекты'];
  static const symbols = [
    PixelSymbol.shop,
    PixelSymbol.yarn,
    PixelSymbol.pattern,
    PixelSymbol.folder,
  ];
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xff38252a),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: LayoutBuilder(
          builder: (context, box) {
            final widths = labels.map((label) {
              final text = TextPainter(textDirection: TextDirection.ltr);
              text.text = TextSpan(
                text: label,
                style: WorkshopType.navigationLabel,
              );
              text.textScaler = MediaQuery.textScalerOf(context);
              text.layout();
              final width = (text.width + 8).clamp(48.0, double.infinity);
              text.dispose();
              return width;
            }).toList();
            final grid = widths.fold<double>(0, (a, b) => a + b) > box.maxWidth;
            Widget tile(int i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                button: true,
                selected: index == i,
                label: labels[i],
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: PixelFrame(
                    bright: index == i,
                    fill: index == i ? wine : const Color(0xff4b302f),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 2,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 36),
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PixelGlyph(symbols[i], size: 22),
                            const SizedBox(height: 3),
                            Text(
                              labels[i],
                              maxLines: 1,
                              softWrap: false,
                              style: WorkshopType.navigationLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            if (grid)
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: tile(0)),
                      Expanded(child: tile(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: tile(2)),
                      Expanded(child: tile(3)),
                    ],
                  ),
                ],
              );
            return Row(
              children: List.generate(
                4,
                (i) => Expanded(flex: widths[i].ceil(), child: tile(i)),
              ),
            );
          },
        ),
      ),
    ),
  );
}
