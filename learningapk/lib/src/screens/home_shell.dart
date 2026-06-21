import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import 'community_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'topics_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        controller: widget.controller,
        onExplore: () => setState(() => _index = 1),
      ),
      TopicsScreen(controller: widget.controller),
      CommunityScreen(controller: widget.controller),
      ProfileScreen(controller: widget.controller),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bolt_outlined),
            selectedIcon: const Icon(Icons.bolt_rounded),
            label: context.tr('learn'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum_rounded),
            label: context.tr('community'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }
}
