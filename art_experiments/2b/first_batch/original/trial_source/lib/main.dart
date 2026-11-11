import 'package:flutter/material.dart';
import 'trial.dart';
import 'projects_on_desk.dart';

void main() => runApp(const MaterialApp(home: DeskTrialPage()));

class DeskTrialPage extends StatefulWidget {
  const DeskTrialPage({super.key});
  @override State<DeskTrialPage> createState() => _DeskTrialPageState();
}
class _DeskTrialPageState extends State<DeskTrialPage> {
  final TrialRoom room = TrialRoom();
  KnittingVariant? selected;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Проба изделий — партия 2Б')),
    body: Column(children: [
      DropdownButton<KnittingVariant?>(
        value: selected,
        items: [const DropdownMenuItem(value: null, child: Text('Пустой стол')),
          for (final variant in KnittingVariant.values)
            DropdownMenuItem(value: variant, child: Text(variant.label))],
        onChanged: (variant) { setState(() => selected = variant); room.selectVariant(variant); },
      ),
      Expanded(child: TrialView(game: room, onTap: (_) {})),
    ]),
  );
}
