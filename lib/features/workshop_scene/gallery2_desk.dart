// Gallery №2: owner-approved placement; Y excludes responsive desk shift.
import 'dart:ui';

enum Gallery2Item {
  sweater('sweater', Rect.fromLTWH(149.14783, 181.54792, 105.73913, 71.19962)),
  socks('socks', Rect.fromLTWH(156.93913, 187.11039, 93.49565, 67.86214)),
  blanket('blanket', Rect.fromLTWH(144.69565, 197.12283, 110.19130, 58.96218)),
  toy('toy', Rect.fromLTWH(155.82609, 174.87295, 130.22609, 84.54955)),
  shawl('shawl', Rect.fromLTWH(145.80870, 206.02278, 135.79130, 64.52465)),
  scarf('scarf', Rect.fromLTWH(154.71304, 199.34782, 111.30435, 76.76209)),
  fabric('fabric', Rect.fromLTWH(143.58261, 210.47276, 134.67826, 75.64960)),
  stole('stole', Rect.fromLTWH(143.58261, 199.34782, 131.33913, 87.88703));

  const Gallery2Item(this.id, this.approvedSceneRect);
  final String id;
  final Rect approvedSceneRect;
  String get assetFile => '$id.png';

  // The icon is independent of category; never infer artwork for other icons.
  static Gallery2Item? fromIconId(String? iconId) {
    for (final item in values) {
      if (item.id == iconId) return item;
    }
    return null;
  }
}
