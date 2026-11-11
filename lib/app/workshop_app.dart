import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'workshop_controller.dart';
import 'theme.dart';
import 'pixel_widgets.dart';
import 'shop_layout.dart';
import '../features/workshop_scene/scene_layout.dart';
import '../features/workshop_scene/workshop_scene_view.dart';
import '../features/counter/counter_panel.dart';
import '../features/projects/create_project_page.dart';
import '../features/projects/project_icon.dart';
import '../features/workshop_scene/workshop_game.dart';

class WorkshopApp extends StatelessWidget {
  const WorkshopApp({super.key, required this.controller});
  final WorkshopController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Лавка забытых историй',
    debugShowCheckedModeBanner: false,
    theme: workshopTheme(),
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: WorkshopShell(controller: controller),
  );
}

class WorkshopShell extends StatefulWidget {
  const WorkshopShell({super.key, required this.controller});
  final WorkshopController controller;
  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell>
    with WidgetsBindingObserver {
  late final WorkshopGame game;
  int tab = 0;
  bool _foreground = true;
  int _covered = 0;
  WorkshopController get c => widget.controller;
  @override
  void initState() {
    super.initState();
    Flame.images.prefix = 'assets/images/';
    game = WorkshopGame();
    WidgetsBinding.instance.addObserver(this);
    c.addListener(_syncScene);
    c.refresh();
  }

  void _syncScene() {
    game.presentation(
      active: _foreground && tab == 0 && _covered == 0,
      reducedMotion: c.snapshot?.reducedMotion ?? false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncScene();
    if (_foreground) c.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    c.removeListener(_syncScene);
    game.pauseEngine();
    super.dispose();
  }

  void _tab(int value) {
    setState(() => tab = value);
    _syncScene();
  }

  Future<T?> _openPage<T>(Widget page) async {
    _covered++;
    _syncScene();
    try {
      return await Navigator.of(context)
          .push<T>(MaterialPageRoute(builder: (_) => page));
    } finally {
      _covered--;
      if (mounted) _syncScene();
    }
  }

  Future<void> _newProject() async {
    final created = await _openPage<bool>(CreateProjectPage(controller: c));
    if (created == true && mounted) _tab(1);
  }

  void _projects() {
    if (c.snapshot!.projects.isEmpty) {
      _newProject();
    } else {
      _tab(3);
    }
  }

  Future<void> _settings() async {
    _covered++;
    _syncScene();
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => AnimatedBuilder(
          animation: c,
          builder: (context, _) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Настроение лавки',
                      style: WorkshopType.sectionTitle,
                    ),
                    const Text('Дождливый вечер · ручная атмосфера'),
                    SwitchListTile(
                      title: const Text('Уменьшить движение'),
                      subtitle: const Text('Статичная атмосфера'),
                      value: c.snapshot!.reducedMotion,
                      onChanged: (value) => c.preferences(reducedMotion: value),
                    ),
                    SwitchListTile(
                      title: const Text('Вибрация счётчика'),
                      value: c.snapshot!.haptics,
                      onChanged: (value) => c.preferences(haptics: value),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _futureRoom(SceneRoute.mail);
                          },
                          child: const Text('Письма · позже'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _futureRoom(SceneRoute.rewards);
                          },
                          child: const Text('Награды · позже'),
                        ),
                      ],
                    ),
                    const Text(
                      'Погода по городу, письма, награды и резервные копии — следующие этапы.',
                      style: WorkshopType.secondary,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Готово'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } finally {
      _covered--;
      if (mounted) _syncScene();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) {
      final s = c.snapshot;
      return Scaffold(
        appBar: WorkshopHeader(
          title: ['Лавка забытых историй', 'Вяжем', 'Узоры', 'Проекты'][tab],
          subtitle: tab == 0 ? 'Гавань · дождливый вечер' : null,
          actions: [
            if (s != null)
              IconButton(
                onPressed: _settings,
                icon: const PixelGlyph(
                  PixelSymbol.settings,
                  size: 24,
                  color: gold,
                ),
                tooltip: 'Настройки атмосферы',
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              if (c.error != null)
                Material(
                  color: const Color(0xffffd5cc),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.error!,
                            style: const TextStyle(color: ink),
                          ),
                        ),
                        TextButton(
                          onPressed: c.refresh,
                          child: const Text('Прочитать снова'),
                        ),
                      ],
                    ),
                  ),
                ),
              // Persisted state only; no misleading 'saved' status before commit.
              if (c.pending > 0) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: s == null
                    ? Center(
                        child: c.error == null
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Данные недоступны',
                                style: TextStyle(color: cream),
                              ),
                      )
                    : IndexedStack(
                        index: tab,
                        children: [
                          _shop(),
                          _knit(),
                          _patterns(),
                          _projectList(),
                        ],
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: WorkshopNavigation(index: tab, onSelect: _tab),
      );
    },
  );

  void _sceneRoute(SceneRoute route) {
    switch (route) {
      case SceneRoute.currentProject:
        if (c.snapshot!.active == null) {
          _newProject();
        } else {
          _tab(1);
        }
      case SceneRoute.patterns:
        _tab(2);
      case SceneRoute.projects:
        _tab(3);
      case SceneRoute.mail:
        _futureRoom(route);
      case SceneRoute.rewards:
        _futureRoom(route);
    }
  }

  void _futureRoom(SceneRoute route) {
    final mail = route == SceneRoute.mail;
    _openPage<void>(
      Scaffold(
        appBar: WorkshopHeader(
          title: mail ? 'Письма из гавани' : 'Сундук наград',
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Paper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PixelGlyph(
                    mail ? PixelSymbol.mail : PixelSymbol.chest,
                    size: 56,
                    color: wine,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Будущий раздел',
                    style: WorkshopType.projectTitle,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mail
                        ? 'Здесь будут письма от жителей гавани и истории, которые можно читать в своём темпе.'
                        : 'Здесь будут заработанные украшения для лавки и коллекция памятных вещей.',
                    style: WorkshopType.bodyText,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Функция пока не реализована. В этом выпуске здесь нет заданий, начислений или предметов для получения.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shop() => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 640.0);
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/workshop_v2/floor_tile.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SingleChildScrollView(
          key: const PageStorageKey('shop-scroll'),
          child: Center(
            child: SizedBox(
              width: width,
              child: ShopLayout(
                viewportHeight: constraints.maxHeight,
                scene: WorkshopSceneView(game: game, onRoute: _sceneRoute),
                card: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: CounterPanel(controller: c, onProjects: _projects),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  Widget _knit() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CounterPanel(controller: c, large: true, onProjects: _projects),
        ],
      ),
    ),
  );
  Widget _patterns() => ListView(
    padding: const EdgeInsets.all(12),
    children: const [
      Paper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PixelGlyph(PixelSymbol.pattern, size: 48, color: wine),
            SizedBox(height: 16),
            Text('Книга узоров', style: WorkshopType.sectionTitle),
            SizedBox(height: 12),
            Text(
              'Раздел следующего этапа. Импорт PDF, PNG и JPG, масштабирование '
              'и отметка места в схеме пока не реализованы.',
            ),
          ],
        ),
      ),
    ],
  );
  Widget _projectList() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      FilledButton.icon(
        onPressed: _newProject,
        icon: const Icon(Icons.add),
        label: const Text('Новый проект'),
      ),
      const SizedBox(height: 16),
      if (c.snapshot!.projects.isEmpty)
        const Paper(
          child: Text(
            'В корзине пока пусто. Добавьте первую работу и выберите её пиксельный знак.',
          ),
        ),
      for (final p in c.snapshot!.projects)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Paper(
            padding: EdgeInsets.zero,
            child: ListTile(
              key: ValueKey('project-${p.id}'),
              contentPadding: const EdgeInsets.all(12),
              minVerticalPadding: 12,
              leading: PixelIcon(icon: p.icon, palette: p.palette),
              title: Text(p.title, style: WorkshopType.projectTitle),
              subtitle: Text('${p.category} · ряд ${p.currentRow}'),
              trailing: p.id == c.snapshot!.activeId
                  ? const Icon(Icons.check_circle, color: wine)
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                if (await c.select(p.id) && mounted) _tab(1);
              },
            ),
          ),
        ),
      const SizedBox(height: 20),
    ],
  );
}
