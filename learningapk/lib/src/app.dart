import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/home_shell.dart';
import 'theme.dart';
import 'widgets/global_realtime_listener.dart';

class LearnLaravelApp extends StatelessWidget {
  const LearnLaravelApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Laravel Kiswahili',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: controller.locale,
      supportedLocales: const [Locale('en'), Locale('sw')],
      home: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final home = controller.isAdmin
              ? AdminShell(controller: controller)
              : HomeShell(controller: controller);
          return controller.isAuthenticated
              ? GlobalRealtimeListener(
                  key: ValueKey(controller.user!['id']),
                  controller: controller,
                  child: home,
                )
              : home;
        },
      ),
    );
  }
}
