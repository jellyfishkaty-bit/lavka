import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lavka/app/workshop_app.dart';
import 'package:lavka/app/workshop_controller.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:lavka/features/projects/create_project_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late WorkshopRepository repo;
  late WorkshopController c;
  setUp(() async {
    repo = await WorkshopRepository.open(
      factory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    await repo.preferences(reducedMotion: true);
    c = WorkshopController(repo);
  });
  tearDown(() async {
    c.dispose();
    await repo.close();
  });
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> fonts() async {
    final body = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-400.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-500.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-600.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Montserrat-700.ttf'));
    await body.load();
    await (FontLoader('Handjet')
          ..addFont(rootBundle.load('assets/fonts/Handjet-500.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Handjet-600.ttf')))
        .load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  }

  testWidgets('real form creates project and row tap commits', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(WorkshopApp(controller: c));
    await settle(tester);
    await tester.tap(find.text('Проекты').last);
    await settle(tester);
    await tester.tap(find.text('Новый проект'));
    await settle(tester);
    expect(find.byType(CreateProjectPage), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Палантин Миссони');
    await tester.ensureVisible(find.byKey(const ValueKey('icon-stole')));
    await tester.tap(find.byKey(const ValueKey('icon-stole')));
    FocusManager.instance.primaryFocus?.unfocus();
    tester.testTextInput.hide();
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('create-save')));
    await settle(tester);
    expect(c.snapshot!.active!.title, 'Палантин Миссони');
    expect(c.snapshot!.active!.iconId, 'stole');
    await tester.tap(find.byKey(const ValueKey('add-row')).hitTestable());
    await settle(tester);
    expect(c.snapshot!.active!.currentRow, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
  testWidgets('small screen, long title, large text has no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await repo.createProject(
      title: 'Очень длинный палантин с орнаментом Миссони для любимой мамы',
      category: 'Палантин',
      craftType: 'needles',
      iconId: 'stole',
      palette: 0,
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: WorkshopApp(controller: c),
      ),
    );
    await settle(tester);
    for (final name in ['Вяжем', 'Проекты', 'Узоры', 'Лавка']) {
      await tester.tap(find.text(name).last);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: name);
    }
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
  testWidgets('capture actual Flutter render with committed sample data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(fonts);
    final id = await repo.createProject(
      title: 'Палантин «Миссони»',
      category: 'Палантин',
      craftType: 'needles',
      iconId: 'stole',
      palette: 0,
    );
    for (var i = 0; i < 13; i++) {
      await repo.changeRow(id, 1);
    }
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: WorkshopApp(controller: c),
      ),
    );
    await settle(tester);
    await settle(tester);
    final directory = Directory('docs/screenshots/v021');
    directory.createSync(recursive: true);
    Future<void> capture(String name) async {
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    }

    await tester.runAsync(() => capture('01-shop'));
    await tester.tap(find.text('Вяжем').last);
    await settle(tester);
    await tester.runAsync(() => capture('02-counter'));
    await tester.tap(find.text('Проекты').last);
    await settle(tester);
    await tester.tap(find.text('Новый проект'));
    await settle(tester);
    await tester.runAsync(() => capture('03-create'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
}
