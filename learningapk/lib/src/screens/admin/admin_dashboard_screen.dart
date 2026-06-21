import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = widget.controller.api.get('/admin/dashboard');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Control Center',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              'Learn Laravel Tanzania',
              style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => widget.controller.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: PagePadding(
        child: ApiFutureBuilder(
          future: _future,
          onRetry: () => setState(_load),
          builder: (context, response) {
            final data = Map<String, dynamic>.from(response['data'] as Map);
            final recent = List<Map<String, dynamic>>.from(
              (data['recent_users'] as List).map(
                (item) => Map<String, dynamic>.from(item as Map),
              ),
            );
            final metrics = [
              ('Students', data['users'], Icons.people_rounded),
              ('Active', data['active_users'], Icons.verified_user_rounded),
              ('Topics', data['topics'], Icons.category_rounded),
              ('Lessons', data['lessons'], Icons.menu_book_rounded),
              ('Quizzes', data['quizzes'], Icons.quiz_rounded),
              ('Messages', data['messages'], Icons.forum_rounded),
            ];
            return RefreshIndicator(
              onRefresh: () async => setState(_load),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF201A2D), Color(0xFF55283C)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      children: [
                        LaravelMark(size: 52),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rogers Charles Eugen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'App owner & administrator',
                                style: TextStyle(color: Color(0xFFD8D1DF)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 112,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFFFE9E7),
                                child: Icon(metric.$3, color: laravelRed),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${metric.$2}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    metric.$1,
                                    style: const TextStyle(
                                      color: Color(0xFF667085),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Users wapya',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...recent.map(
                    (user) => Card(
                      child: ListTile(
                        leading: UserAvatar(user: user),
                        title: Text(user['name'].toString()),
                        subtitle: Text(user['email'].toString()),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
