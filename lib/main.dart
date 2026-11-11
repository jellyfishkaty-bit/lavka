import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/workshop_app.dart';
import 'app/workshop_controller.dart';
import 'app/theme.dart';
import 'core/storage/workshop_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  WorkshopController? controller;
  String? error;
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    setState(() => error = null);
    try {
      final repository = await WorkshopRepository.open();
      if (!mounted) {
        await repository.close();
        return;
      }
      setState(() => controller = WorkshopController(repository));
    } catch (exception, stack) {
      debugPrint('Storage startup failed: $exception\n$stack');
      if (mounted)
        setState(
          () => error =
              'Не удалось открыть локальное хранилище. '
              'Данные не удалены. '
              '${exception is MissingPluginException ? 'Модуль базы данных отсутствует в сборке. Установите исправленную версию приложения.' : 'Закройте приложение и попробуйте открыть снова.'}',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) return WorkshopApp(controller: controller!);
    return MaterialApp(
      theme: workshopTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, style: const TextStyle(color: cream)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _open,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
