import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/app_controller.dart';
import 'src/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(ApiService());
  try {
    await controller.restoreSession();
  } catch (_) {
    // A damaged local preference must never prevent the app from starting.
  }
  runApp(LearnLaravelApp(controller: controller));
}
