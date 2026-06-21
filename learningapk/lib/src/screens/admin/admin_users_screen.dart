import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../widgets/common.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _search = TextEditingController();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final query = Uri.encodeQueryComponent(_search.text.trim());
    _future = widget.controller.api.get('/admin/users?search=$query');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage users',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: PagePadding(
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Tafuta jina au email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => setState(_load),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: (_) => setState(_load),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ApiFutureBuilder(
                future: _future,
                onRetry: () => setState(_load),
                builder: (context, response) {
                  final page = Map<String, dynamic>.from(
                    response['data'] as Map,
                  );
                  final users = List<Map<String, dynamic>>.from(
                    (page['data'] as List).map(
                      (item) => Map<String, dynamic>.from(item as Map),
                    ),
                  );
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final active = user['is_active'] == true;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              UserAvatar(user: user),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: active ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            user['name'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(user['email'].toString()),
                          trailing: Switch(
                            value: active,
                            onChanged: (_) async {
                              await widget.controller.api.patch(
                                '/admin/users/${user['id']}/toggle',
                              );
                              setState(_load);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
