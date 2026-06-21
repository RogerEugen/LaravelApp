import 'dart:async';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../auth_gate.dart';
import '../services/realtime_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  Future<Map<String, dynamic>>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.controller.isAuthenticated) _load();
  }

  void _load() {
    _future = widget.controller.api.get('/community/contacts');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Laravel Community TZ',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: EmptyStateWithAction(
          icon: Icons.forum_rounded,
          title: 'Jiunge na community',
          message:
              'Jisajili ili uongee moja kwa moja na admin, uulize maswali na kupata msaada wa Laravel.',
          label: 'Jisajili au ingia',
          onPressed: () async {
            if (await requireCommunityLogin(context, widget.controller)) {
              setState(_load);
            }
          },
        ),
      );
    }

    _future ??= widget.controller.api.get('/community/contacts');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.controller.isAdmin ? 'Students chat' : 'Laravel Community TZ',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: PagePadding(
        child: ApiFutureBuilder(
          future: _future!,
          onRetry: () => setState(_load),
          builder: (context, response) {
            final contacts = List<Map<String, dynamic>>.from(
              (response['data'] as List).map(
                (item) => Map<String, dynamic>.from(item as Map),
              ),
            );
            if (contacts.isEmpty) {
              return const EmptyState(
                icon: Icons.forum_outlined,
                title: 'Hakuna mazungumzo bado',
                message: 'Contacts wataonekana hapa.',
              );
            }
            return ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final unread = contact['unread_count'] as int? ?? 0;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFE9E7),
                      child: Text(
                        contact['name'].toString()[0].toUpperCase(),
                        style: const TextStyle(
                          color: laravelRed,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    title: Text(
                      contact['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      contact['username']?.toString() ??
                          contact['email'].toString(),
                    ),
                    trailing: unread > 0
                        ? Badge(label: Text('$unread'))
                        : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          controller: widget.controller,
                          contact: contact,
                        ),
                      ),
                    ).then((_) => setState(_load)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.controller,
    required this.contact,
  });
  final AppController controller;
  final Map<String, dynamic> contact;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  late final RealtimeService _realtime;
  StreamSubscription<Map<String, dynamic>>? _live;
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _realtime = RealtimeService(widget.controller.api);
    _start();
  }

  Future<void> _start() async {
    try {
      final response = await widget.controller.api.get(
        '/community/conversations/${widget.contact['id']}',
      );
      _messages = List<Map<String, dynamic>>.from(
        (response['data'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      _live = _realtime.messages.listen((message) {
        final contactId = widget.contact['id'];
        if (message['sender_id'] == contactId ||
            message['recipient_id'] == contactId) {
          if (!_messages.any((item) => item['id'] == message['id'])) {
            setState(() => _messages.add(message));
            _jumpToBottom();
          }
        }
      });
      await _realtime.connect(widget.controller.user!['id'] as int);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _jumpToBottom();
      }
    }
  }

  Future<void> _send() async {
    final message = _text.text.trim();
    if (message.isEmpty || _sending) return;
    setState(() => _sending = true);
    _text.clear();
    try {
      final response = await widget.controller.api.post(
        '/community/conversations/${widget.contact['id']}',
        {'message': message},
      );
      final sent = Map<String, dynamic>.from(response['data'] as Map);
      if (!_messages.any((item) => item['id'] == sent['id'])) {
        setState(() => _messages.add(sent));
      }
      _jumpToBottom();
    } catch (error) {
      _text.text = message;
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _live?.cancel();
    _realtime.dispose();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentId = widget.controller.user!['id'];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contact['name'].toString(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const Text(
              'Realtime kupitia Laravel Reverb',
              style: TextStyle(fontSize: 11, color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(18),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final item = _messages[index];
                      final mine = item['sender_id'] == currentId;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: mine ? laravelRed : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(mine ? 18 : 4),
                              bottomRight: Radius.circular(mine ? 4 : 18),
                            ),
                          ),
                          child: Text(
                            item['message'].toString(),
                            style: TextStyle(
                              color: mine ? Colors.white : ink,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Andika ujumbe...',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWithAction extends StatelessWidget {
  const EmptyStateWithAction({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String message;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: laravelRed),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085), height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: onPressed, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
