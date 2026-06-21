import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/home_shell.dart';
import 'theme.dart';

class LearnLaravelApp extends StatelessWidget {
  const LearnLaravelApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Laravel Kiswahili',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => controller.isAdmin
            ? AdminShell(controller: controller)
            : HomeShell(controller: controller),
      ),
    );
  }
}
