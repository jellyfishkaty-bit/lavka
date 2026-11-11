import 'dart:io';
import 'package:flame/components.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_check/trial.dart';
import 'package:scene_check/scene_layout.dart';
void main(){
 for(final size in [const Size(320,307),const Size(360,405),const Size(384,480),const Size(393,493),const Size(430,400),const Size(384,520)]){
  testWidgets('responsive targets and scene $size',(t)async{
   t.view.physicalSize=size;t.view.devicePixelRatio=1;addTearDown(t.view.reset);
   SceneRoute? tapped;final g=TrialRoom(),key=GlobalKey();
   await t.pumpWidget(MaterialApp(home:RepaintBoundary(key:key,child:TrialView(game:g,onTap:(route)=>tapped=route))));
   for(var i=0;i<60 && (!g.isLoaded||g.world.children.whereType<PositionComponent>().length<10);i++){await t.runAsync(()=>Future<void>.delayed(const Duration(milliseconds:100)));await t.pump();}
   expect(g.isLoaded,true);await t.pump(const Duration(milliseconds:30));
   final view=RoomViewport(size);
   for(final target in roomTargets){
    final rect=view.target(view.targetBounds(target),size);
    expect(rect.width,greaterThanOrEqualTo(48));expect(rect.height,greaterThanOrEqualTo(48));
    expect(rect.left,greaterThanOrEqualTo(0));expect(rect.right,lessThanOrEqualTo(size.width));
   }
   for(final route in SceneRoute.values){
    final target=roomTargets.firstWhere((t)=>t.route==route);
    final rect=view.target(view.targetBounds(target),size);
    if(route==SceneRoute.currentProject || route==SceneRoute.patterns || route==SceneRoute.projects || route==SceneRoute.rewards){
      final id = switch (route) { SceneRoute.currentProject => 'desk', SceneRoute.patterns => 'bookcase', SceneRoute.projects => 'basket', SceneRoute.rewards => 'chest', _ => throw StateError('unexpected') };
      final component=g.sprites[id]!;
      final painted=view.project(Rect.fromLTWH(component.position.x,component.position.y,component.size.x,component.size.y));
      expect(painted.contains(rect.center),true,reason:'target center must be on its sprite');
    }
    await t.tap(find.byKey(ValueKey('trial-${route.name}')));await t.pump();expect(tapped,route);
   }
   if(size.width==384||size.width==320||size.width==393){await t.runAsync(()async{
    final im=await (key.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio:3);
    final data=await im.toByteData(format:ui.ImageByteFormat.png);
    await Directory('build/test_renders').create(recursive:true);
    await File('build/test_renders/render_${size.width.toInt()}_${size.height.toInt()}.png').writeAsBytes(data!.buffer.asUint8List());im.dispose();
   });}
   expect(t.takeException(),isNull);await t.pumpWidget(const SizedBox());
  });
 }
}
