import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Measure the real card first, then give the room the remaining viewport.
/// On short phones/large text the outer scroll view exposes all content.
/// No text-scale heuristics or intrinsic queries into Flame's LayoutBuilder.
class ShopLayout extends MultiChildRenderObjectWidget {
  ShopLayout({
    super.key,
    required this.viewportHeight,
    required Widget scene,
    required Widget card,
  }) : super(children: [scene, card]);
  final double viewportHeight;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ShopBox(viewportHeight);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ShopBox renderObject,
  ) {
    renderObject.viewportHeight = viewportHeight;
  }
}

class _ShopData extends ContainerBoxParentData<RenderBox> {}

class _ShopBox extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _ShopBox(this._viewportHeight);
  double _viewportHeight;
  set viewportHeight(double value) {
    if (value == _viewportHeight) return;
    _viewportHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>)
      child.parentData = _ShopData();
  }

  @override
  void performLayout() {
    final scene = firstChild!, card = lastChild!, width = constraints.maxWidth;
    card.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
    final sceneHeight = math.max(
      width * 368 / 384,
      _viewportHeight - card.size.height,
    );
    scene.layout(
      BoxConstraints.tight(Size(width, sceneHeight)),
      parentUsesSize: true,
    );
    (scene.parentData! as ContainerBoxParentData<RenderBox>).offset =
        Offset.zero;
    (card.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
      0,
      sceneHeight,
    );
    size = constraints.constrain(Size(width, sceneHeight + card.size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
