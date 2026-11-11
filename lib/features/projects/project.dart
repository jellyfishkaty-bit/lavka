class ProjectIcon {
  const ProjectIcon(this.id, this.label);
  final String id;
  final String label;
  String get asset => 'assets/images/icons/$id.png';
}

const projectIcons = [
  ProjectIcon('shawl', 'Шаль'),
  ProjectIcon('scarf', 'Шарф'),
  ProjectIcon('stole', 'Палантин'),
  ProjectIcon('sweater', 'Свитер'),
  ProjectIcon('cardigan', 'Кардиган'),
  ProjectIcon('socks', 'Носки'),
  ProjectIcon('mittens', 'Варежки'),
  ProjectIcon('hat', 'Шапка'),
  ProjectIcon('blanket', 'Плед'),
  ProjectIcon('toy', 'Игрушка'),
  ProjectIcon('yarn', 'Клубок'),
  ProjectIcon('star', 'Звезда'),
  ProjectIcon('lighthouse', 'Маяк'),
  ProjectIcon('flower', 'Цветок'),
  ProjectIcon('basket', 'Корзина'),
  ProjectIcon('teacup', 'Чашка'),
];

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.category,
    required this.craftType,
    required this.iconId,
    required this.palette,
    required this.currentRow,
  });
  final int id;
  final String title, category, craftType, iconId;
  final int palette, currentRow;
  ProjectIcon get icon => projectIcons.firstWhere(
    (i) => i.id == iconId,
    orElse: () => projectIcons[10],
  );
  factory Project.fromMap(Map<String, Object?> m) => Project(
    id: m['id'] as int,
    title: m['title'] as String,
    category: m['category'] as String,
    craftType: m['craft_type'] as String,
    iconId: m['icon_id'] as String,
    palette: m['palette'] as int,
    currentRow: m['current_row'] as int,
  );
}

class WorkshopSnapshot {
  const WorkshopSnapshot({
    required this.projects,
    required this.activeId,
    required this.today,
    required this.total,
    required this.canUndo,
    required this.reducedMotion,
    required this.haptics,
  });
  final List<Project> projects;
  final int? activeId;
  final int today, total;
  final bool canUndo, reducedMotion, haptics;
  Project? get active {
    for (final p in projects) {
      if (p.id == activeId) return p;
    }
    return null;
  }
}
