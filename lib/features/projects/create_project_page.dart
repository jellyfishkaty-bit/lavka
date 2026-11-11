import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../app/workshop_controller.dart';
import 'project.dart';
import 'project_icon.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key, required this.controller});
  final WorkshopController controller;
  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _category = 'Шаль', _craft = 'needles', _iconId = 'shawl';
  int _palette = 0;
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.controller.create(
      title: _title.text,
      category: _category,
      craftType: _craft,
      iconId: _iconId,
      palette: _palette,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _error = widget.controller.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: const WorkshopHeader(title: 'Новая история'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const ValueKey('create-save'),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Сохраняем…' : 'Создать проект'),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            Paper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Что будем вязать?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    maxLength: 80,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Название проекта',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Дайте проекту название'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Категория'),
                    items:
                        [
                              'Шаль',
                              'Шарф',
                              'Палантин',
                              'Одежда',
                              'Аксессуар',
                              'Для дома',
                              'Игрушка',
                              'Другое',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: _saving
                        ? null
                        : (s) => setState(() => _category = s!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _craft,
                    decoration: const InputDecoration(labelText: 'Техника'),
                    items: const [
                      DropdownMenuItem(value: 'needles', child: Text('Спицы')),
                      DropdownMenuItem(value: 'hook', child: Text('Крючок')),
                      DropdownMenuItem(value: 'other', child: Text('Иное')),
                    ],
                    onChanged: _saving
                        ? null
                        : (s) => setState(() => _craft = s!),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Знак проекта',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text('Выбирается независимо от категории.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projectIcons
                        .map(
                          (icon) => Semantics(
                            selected: icon.id == _iconId,
                            child: Tooltip(
                              message: icon.label,
                              child: InkWell(
                                key: ValueKey('icon-${icon.id}'),
                                onTap: _saving
                                    ? null
                                    : () => setState(() => _iconId = icon.id),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color: icon.id == _iconId
                                          ? wine
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: PixelIcon(
                                    icon: icon,
                                    palette: _palette,
                                    size: 52,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Цвет подложки'),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      4,
                      (i) => Semantics(
                        label: [
                          'Пергамент',
                          'Морская бирюза',
                          'Роза',
                          'Сумерки',
                        ][i],
                        selected: _palette == i,
                        button: true,
                        child: InkWell(
                          onTap: _saving
                              ? null
                              : () => setState(() => _palette = i),
                          child: Container(
                            width: 52,
                            height: 52,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: iconBackdrops[i],
                              border: Border.all(
                                color: _palette == i ? wine : gold,
                                width: 3,
                              ),
                            ),
                            child: _palette == i
                                ? const Icon(Icons.check, color: ink)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xff8b1f2e)),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
