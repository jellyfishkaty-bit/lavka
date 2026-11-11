import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_check/trial.dart';
import 'package:scene_check/projects_on_desk.dart';

void main() {
  test('mapping does not infer an object from icon or broad category', () {
    expect(variantForCategory(null), isNull);
    expect(variantForCategory('Шаль'), KnittingVariant.shawl);
    expect(variantForCategory('Одежда'), KnittingVariant.fabric);
    expect(variantForCategory('Для дома'), KnittingVariant.fabric);
    expect(variantForCategory('Носки'), KnittingVariant.socks);
  });
  testWidgets('all variants switch in one scene and render at mobile size', (t) async {
    t.view.physicalSize = const Size(384, 480);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final g = TrialRoom(), key = GlobalKey();
    await t.pumpWidget(MaterialApp(home: RepaintBoundary(key:key,
      child: TrialView(game:g,onTap: (_) {}))));
    for (var i=0; i<120 && !g.isLoaded; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds:100)));
      await t.pump();
    }
    expect(g.isLoaded, isTrue);
    Directory('build/project_renders').createSync(recursive:true);
    expect(g.selectedVariant, isNull);
    for (final variant in KnittingVariant.values) {
      g.selectVariant(variant);
      await t.pump(const Duration(milliseconds:30));
      expect(g.selectedVariant, variant);
      expect(g.projectSprite!.size.x, greaterThan(0));
      expect(g.projectSprite!.sprite, same(g.projectSprites[variant]));
      await t.runAsync(() async {
        final im = await (key.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio:3);
        final data = await im.toByteData(format:ui.ImageByteFormat.png);
        await File('build/project_renders/${variant.name}.png').writeAsBytes(data!.buffer.asUint8List());
        im.dispose();
      });
    }
    g.selectVariant(null); await t.pump();
    expect(g.projectSprite!.size.x, 0);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
