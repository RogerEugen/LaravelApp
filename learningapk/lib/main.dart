import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/app_controller.dart';
import 'src/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(ApiService());
  await controller.restoreSession();
  runApp(LearnLaravelApp(controller: controller));
}
