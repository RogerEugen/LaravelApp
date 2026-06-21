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
        actions: [
          IconButton(
            tooltip: 'Add support expert',
            onPressed: _addSupport,
            icon: const Icon(Icons.support_agent_rounded),
          ),
        ],
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
                  onPressed: () => setState(() {
                    _load();
                  }),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: (_) => setState(() {
                _load();
              }),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ApiFutureBuilder(
                future: _future,
                onRetry: () => setState(() {
                  _load();
                }),
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
                              setState(() {
                                _load();
                              });
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

  Future<void> _addSupport() async {
    final name = TextEditingController();
    final username = TextEditingController();
    final email = TextEditingController();
    final expertise = TextEditingController();
    final bio = TextEditingController();
    final password = TextEditingController(text: 'support123');
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Register support expert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: expertise,
                decoration: const InputDecoration(
                  labelText: 'Laravel expertise',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bio,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Short bio'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: password,
                decoration: const InputDecoration(
                  labelText: 'Temporary password',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await widget.controller.api.post('/admin/supports', {
                'name': name.text.trim(),
                'username': username.text.trim(),
                'email': email.text.trim(),
                'expertise': expertise.text.trim(),
                'bio': bio.text.trim(),
                'password': password.text,
              });
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            },
            child: const Text('Create expert'),
          ),
        ],
      ),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support expert registered.')),
      );
    }
  }
}
