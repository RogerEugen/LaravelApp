import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../auth_gate.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'progress_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Akaunti',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: EmptyStateWithProfileAction(controller: controller),
      );
    }

    final user = controller.user!;
    final name = user['name'].toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wasifu',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: PagePadding(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFFFFE9E7),
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: laravelRed,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              user['email'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
            const SizedBox(height: 28),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.insights, color: laravelRed),
                    title: const Text('Maendeleo yangu'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(controller: controller),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.language, color: laravelRed),
                    title: Text('Lugha'),
                    trailing: Text('Kiswahili'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.phone_android, color: laravelRed),
                    title: Text('Android'),
                    trailing: Text('7.0+'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: laravelRed,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => controller.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Toka kwenye akaunti'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWithProfileAction extends StatelessWidget {
  const EmptyStateWithProfileAction({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt_1, size: 64, color: laravelRed),
            const SizedBox(height: 16),
            Text(
              'Learning community yako',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            const Text(
              'Masomo ni bure bila login. Akaunti inakupa quiz, progress na realtime chat na admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF667085), height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => requireCommunityLogin(context, controller),
              child: const Text('Jisajili au ingia'),
            ),
          ],
        ),
      ),
    );
  }
}
