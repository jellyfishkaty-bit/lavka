import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../app/pixel_widgets.dart';
import '../../app/workshop_controller.dart';
import '../projects/project_icon.dart';

class CounterPanel extends StatelessWidget {
  const CounterPanel({
    super.key,
    required this.controller,
    this.large = false,
    required this.onProjects,
  });
  final WorkshopController controller;
  final bool large;
  final VoidCallback onProjects;
  void _change(int id, int delta) {
    if (controller.snapshot!.haptics) HapticFeedback.selectionClick();
    controller.row(id, delta);
  }

  @override
  Widget build(BuildContext context) {
    final s = controller.snapshot!;
    final p = s.active;
    if (p == null) {
      return Paper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Здесь начнётся ваша история',
              style: WorkshopType.projectTitle,
            ),
            const SizedBox(height: 6),
            const Text('Создайте проект и свяжите первый ряд.'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onProjects,
              child: const Text('Создать проект'),
            ),
          ],
        ),
      );
    }
    final undo = TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      onPressed: s.canUndo ? () => controller.undo(p.id) : null,
      icon: const Icon(Icons.undo, size: 20),
      label: Text(
        large ? 'Отменить последнее действие' : 'Отмена',
        style: WorkshopType.secondary,
      ),
    );
    final stats = Wrap(
      spacing: 12,
      runSpacing: 2,
      children: [
        Text('Сегодня: ${s.today}', style: WorkshopType.secondary),
        Text('Всего: ${s.total}', style: WorkshopType.secondary),
      ],
    );
    return Paper(
      padding: EdgeInsets.all(large ? 12 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PixelIcon(
                icon: p.icon,
                palette: p.palette,
                size: large ? 48 : 36,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: p.title,
                  child: Text(
                    p.title,
                    style: WorkshopType.projectTitle,
                    maxLines: large ? null : 1,
                    overflow: large ? null : TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                onPressed: onProjects,
                icon: const PixelGlyph(PixelSymbol.swap, size: 22, color: wine),
                tooltip: 'Выбрать другой проект',
              ),
            ],
          ),
          if (large) ...[
            Text(p.category, style: WorkshopType.secondary),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  'Ряд ${p.currentRow}',
                  key: const ValueKey('current-row'),
                  style: WorkshopType.counterValue,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, box) {
              final bigText = MediaQuery.textScalerOf(context).scale(20) > 25;
              final row = Semantics(
                liveRegion: true,
                child: Text(
                  'Ряд ${p.currentRow}',
                  key: const ValueKey('current-row'),
                  style: WorkshopType.rowValue,
                ),
              );
              final buttons = Row(
                children: [
                  Semantics(
                    label: 'Распустить один ряд',
                    button: true,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: p.currentRow > 0
                          ? () => _change(p.id, -1)
                          : null,
                      child: const Text('−1', style: WorkshopType.projectTitle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('add-row'),
                      onPressed: () => _change(p.id, 1),
                      style: FilledButton.styleFrom(
                        minimumSize: Size(48, large ? 100 : 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        '+1 ряд',
                        style: large
                            ? WorkshopType.largeButton
                            : WorkshopType.buttonText,
                      ),
                    ),
                  ),
                ],
              );
              if (large) return buttons;
              // Large system text and long numbers get another row, never a tiny font.
              if (bigText || p.currentRow > 9999)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [row, const SizedBox(height: 4), buttons],
                );
              return Row(
                children: [
                  Expanded(flex: 2, child: row),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: buttons),
                ],
              );
            },
          ),
          if (large) ...[
            const SizedBox(height: 12),
            stats,
            undo,
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'Как работает счётчик',
                style: WorkshopType.secondary,
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '−1 — распустить ряд; сделанная работа остаётся в статистике. Ошиблись нажатием? Используйте отмену. Статистика общая для всех проектов.',
                    style: WorkshopType.bodyText,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(child: stats),
                undo,
              ],
            ),
        ],
      ),
    );
  }
}
