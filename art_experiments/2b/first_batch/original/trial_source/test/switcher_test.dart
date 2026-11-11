import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_check/main.dart';
import 'package:scene_check/projects_on_desk.dart';

void main() {
  testWidgets('trial dropdown switches variants', (tester) async {
    tester.view.physicalSize = const Size(384, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DeskTrialPage()));
    await tester.tap(find.byType(DropdownButton<KnittingVariant?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Шаль').last);
    await tester.pump();
    expect(tester.widget<DropdownButton<KnittingVariant?>>(find.byType(DropdownButton<KnittingVariant?>)).value, KnittingVariant.shawl);
    await tester.pumpWidget(const SizedBox());
  });
}
