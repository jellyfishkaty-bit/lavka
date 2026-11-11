import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'scene_layout.dart';
import 'projects_on_desk.dart';

class TrialRoom extends FlameGame {
  TrialRoom({KnittingVariant? variant}) : selectedVariant = variant;
  KnittingVariant? selectedVariant;
  final Map<KnittingVariant, Sprite> projectSprites = {};
  SpriteComponent? projectSprite;

  void selectVariant(KnittingVariant? variant) {
    selectedVariant = variant;
    _position();
  }

  RoomViewport geometry=RoomViewport(const Size(384,432));
  final Map<String,SpriteComponent> sprites={};
  @override void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if(size.x<=0||size.y<=0)return;
    geometry=RoomViewport(Size(size.x,size.y));
    camera.viewfinder.anchor=Anchor.topLeft;
    camera.viewfinder.zoom=geometry.scale;
    camera.viewfinder.position=Vector2(-geometry.offset.dx/geometry.scale,-geometry.offset.dy/geometry.scale);
    _position();
  }
  void _position(){
    sprites['walls']?.size.y=math.max(480.0, geometry.height);
    sprites['desk']?.position.y=215+geometry.shift('desk');
    sprites['chair']?.position.y=210+geometry.shift('chair');
    sprites['rug']?.position.y=329+geometry.shift('rug');
    sprites['cat']?.position.y=363+geometry.shift('cat');
    sprites['basket']?.position.y=315+geometry.shift('basket');
    sprites['chest']?.position.y=326+geometry.shift('chest');
    final component = projectSprite;
    final variant = selectedVariant;
    if (component != null) {
      if (variant == null) {
        component.size = Vector2.zero();
      } else if (projectSprites.containsKey(variant)) {
        final sprite = projectSprites[variant]!;
        final box = variantBounds(variant, Size(sprite.srcSize.x, sprite.srcSize.y), geometry.shift('desk'));
        component.sprite = sprite;
        component.position = Vector2(box.left, box.top);
        component.size = Vector2(box.width, box.height);
      }
    }
  }
  @override Future<void> onLoad() async {
    Future<void> addLayer(String id,String asset,Rect rect,int z,{bool cutFeet=false})async{
      final base=await loadSprite('workshop_trial/$asset.png');
      final sprite=cutFeet?Sprite(base.image,srcPosition:Vector2.zero(),srcSize:Vector2(base.image.width.toDouble(),base.image.height*0.84)):base;
      final part=SpriteComponent(sprite:sprite,position:Vector2(rect.left,rect.top),size:Vector2(rect.width,rect.height),priority:z,paint:Paint()..filterQuality=FilterQuality.none..isAntiAlias=false);
      sprites[id]=part;await world.add(part);
    }
    await addLayer('walls','walls_floor_revision',const Rect.fromLTWH(0,0,384,480),0);
    await addLayer('harbor','harbor_masked',const Rect.fromLTWH(5,8,176,220),10);
    await addLayer('window','window',const Rect.fromLTWH(5,8,176,220),20);
    await addLayer('bookcase','bookcase_revision',const Rect.fromLTWH(151,10,247,309),22);
    await addLayer('rug','rug_2a',const Rect.fromLTWH(12,329,360,101.17),25);
    await addLayer('chair','chair',const Rect.fromLTWH(0,210,125,151),30);
    await addLayer('desk','desk_revision',const Rect.fromLTWH(97,215,240,120),32);
    await addLayer('basket','basket_2a',const Rect.fromLTWH(117,315,70,87.1),45);
    await addLayer('chest','chest_2a',const Rect.fromLTWH(266,326,109,85.26),46);
    await addLayer('cat','cat_2a',const Rect.fromLTWH(25,363,104,67.91),48);
    for (final variant in KnittingVariant.values) {
      projectSprites[variant] = await loadSprite(variant.asset);
    }
    projectSprite = SpriteComponent(sprite: projectSprites[KnittingVariant.fabric]!, size: Vector2.zero(), priority: 33, paint: Paint()..filterQuality=FilterQuality.none..isAntiAlias=false);
    await world.add(projectSprite!);
    _position();
  }
}
class TrialView extends StatelessWidget {
 const TrialView({super.key,required this.game,required this.onTap});
 final TrialRoom game; final ValueChanged<SceneRoute> onTap;
 @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,box){
   final size=Size(box.maxWidth,box.maxHeight),v=RoomViewport(size);
   return ClipRect(child:Stack(children:[Positioned.fill(child:GameWidget(game:game)),
     for(final t in roomTargets) Positioned.fromRect(rect:v.target(v.targetBounds(t),size),child:Material(type:MaterialType.transparency,child:InkWell(key:ValueKey('trial-${t.route.name}'),onTap:()=>onTap(t.route)))),
   ]));
 });
}
