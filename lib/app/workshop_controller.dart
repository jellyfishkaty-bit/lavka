import 'package:flutter/foundation.dart';

import '../core/storage/workshop_repository.dart';
import '../features/projects/project.dart';

class WorkshopController extends ChangeNotifier {
  WorkshopController(this.repository);
  final WorkshopRepository repository;
  WorkshopSnapshot? snapshot;
  String? error;
  int pending = 0;
  Future<void> _queue = Future.value();

  /// Commands are serialized; IDs are captured at tap time, never read later.
  /// UI reflects committed data only. Failed writes do not advance counters.
  Future<bool> run(Future<void> Function() action) async {
    pending++;
    notifyListeners();
    var success = false;
    final command = _queue.then((_) async {
      try {
        await action();
        snapshot = await repository.load();
        error = null;
        success = true;
      } catch (_) {
        error =
            'Не удалось подтвердить данные. '
            'Проверьте свободное место и перечитайте сохранённые данные.';
      } finally {
        pending--;
        notifyListeners();
      }
    });
    _queue = command;
    await command;
    return success;
  }

  Future<bool> refresh() => run(() async {});
  Future<bool> select(int id) => run(() => repository.selectProject(id));
  Future<bool> row(int id, int delta) =>
      run(() => repository.changeRow(id, delta));
  Future<bool> undo(int id) => run(() => repository.undo(id));
  Future<bool> create({
    required String title,
    required String category,
    required String craftType,
    required String iconId,
    required int palette,
  }) => run(() async {
    await repository.createProject(
      title: title,
      category: category,
      craftType: craftType,
      iconId: iconId,
      palette: palette,
    );
  });
  Future<bool> preferences({bool? reducedMotion, bool? haptics}) => run(
    () =>
        repository.preferences(reducedMotion: reducedMotion, haptics: haptics),
  );
}
