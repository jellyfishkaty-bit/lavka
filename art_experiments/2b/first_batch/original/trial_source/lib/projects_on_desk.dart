import 'package:flutter/widgets.dart';

enum KnittingVariant { scarf, shawl, stole, socks, sweater, toy, blanket, fabric }

extension KnittingVariantDescription on KnittingVariant {
  String get label => switch (this) {
    KnittingVariant.scarf => 'Шарф', KnittingVariant.shawl => 'Шаль',
    KnittingVariant.stole => 'Палантин', KnittingVariant.socks => 'Носки',
    KnittingVariant.sweater => 'Свитер', KnittingVariant.toy => 'Игрушка',
    KnittingVariant.blanket => 'Плед', KnittingVariant.fabric => 'Полотно',
  };
  String get asset => 'workshop_trial/project_${name}_2b.png';
}

/// Tentative category mapping. Broad existing categories must not be guessed
/// from an icon; null means no active project, unknown categories use fabric.
KnittingVariant? variantForCategory(String? category) {
  if (category == null) return null;
  return switch (category.trim().toLowerCase()) {
    'шаль' => KnittingVariant.shawl,
    'шарф' => KnittingVariant.scarf,
    'палантин' => KnittingVariant.stole,
    'игрушка' => KnittingVariant.toy,
    'носки' => KnittingVariant.socks,
    'свитер' || 'кардиган' => KnittingVariant.sweater,
    'плед' => KnittingVariant.blanket,
    _ => KnittingVariant.fabric,
  };
}

class Placement {
  const Placement(this.left, this.bottom, this.width);
  final double left, bottom, width;
}

/// Coordinates are room-space units; aspect ratio comes from the PNG itself.
const placements = <KnittingVariant, Placement>{
  KnittingVariant.scarf: Placement(189, 261, 77),
  KnittingVariant.shawl: Placement(191, 252, 76),
  KnittingVariant.stole: Placement(198, 281, 67),
  KnittingVariant.socks: Placement(191, 250, 70),
  KnittingVariant.sweater: Placement(191, 254, 74),
  KnittingVariant.toy: Placement(195, 249, 63),
  KnittingVariant.blanket: Placement(190, 255, 78),
  KnittingVariant.fabric: Placement(188, 249, 78),
};

Rect variantBounds(KnittingVariant variant, Size image, double shift) {
  final p = placements[variant]!;
  final height = p.width * image.height / image.width;
  return Rect.fromLTWH(p.left, p.bottom - height + shift, p.width, height);
}
