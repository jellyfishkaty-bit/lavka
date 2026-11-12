import 'package:flutter_test/flutter_test.dart';
import 'package:lavka/features/workshop_scene/scene_layout.dart';

void main() {
  test('approved Gallery2 backdrop contains bare desk and no legacy lamp or mug', () {
    expect(roomObjects.length, 10);
    final ids = roomObjects.map((o) => o.id).toSet();
    expect(ids, containsAll(['walls','harbor','window','bookcase','desk','chair','rug','basket','chest','cat']));
    expect(ids, isNot(contains('lamp')));
    expect(ids, isNot(contains('mug')));
    final desk = roomObjects.singleWhere((o) => o.id == 'desk');
    expect(desk.asset, 'desk_revision.png');
    expect(desk.bounds, const Rect.fromLTWH(97, 215, 240, 120));
  });
}
