import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'screens/auth_screen.dart';

Future<bool> requireCommunityLogin(
  BuildContext context,
  AppController controller,
) async {
  if (controller.isAuthenticated) return true;

  return await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AuthScreen(controller: controller),
        ),
      ) ??
      false;
}
