import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lavka/app/workshop_app.dart';
import 'package:lavka/app/workshop_controller.dart';
import 'package:lavka/core/storage/workshop_repository.dart';
import 'package:lavka/features/workshop_scene/workshop_scene_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('counter save progress does not resize workshop viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = await WorkshopRepository.open(
      factory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final controller = WorkshopController(repo);
    await repo.createProject(
      title: 'Проверка счётчика',
      category: 'Шаль',
      craftType: 'needles',
      iconId: 'shawl',
      palette: 0,
    );
    await tester.pumpWidget(WorkshopApp(controller: controller));
    for (var i = 0; i < 30 && controller.snapshot == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 70)),
      );
      await tester.pump();
    }
    expect(controller.snapshot, isNotNull);
    await tester.pump(const Duration(milliseconds: 100));

    final slot = find.byKey(const ValueKey('save-progress-slot'));
    final room = find.byType(WorkshopSceneView);
    expect(slot, findsOneWidget);
    expect(room, findsOneWidget);
    final idleRoom = tester.getRect(room);
    expect(tester.getSize(slot).height, 2);

    final gate = Completer<void>();
    final save = controller.run(() => gate.future);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.getSize(slot).height, 2);
    expect(tester.getRect(room), idleRoom,
        reason: 'Saving must not move the room or the desk');

    gate.complete();
    await tester.runAsync(() => save);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.getSize(slot).height, 2);
    expect(tester.getRect(room), idleRoom,
        reason: 'Save completion must not cause a second jump');

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    controller.dispose();
    await repo.close();
  });
}
