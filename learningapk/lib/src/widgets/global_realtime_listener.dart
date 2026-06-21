import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../services/realtime_service.dart';

class GlobalRealtimeListener extends StatefulWidget {
  const GlobalRealtimeListener({
    super.key,
    required this.controller,
    required this.child,
  });

  final AppController controller;
  final Widget child;

  @override
  State<GlobalRealtimeListener> createState() => _GlobalRealtimeListenerState();
}

class _GlobalRealtimeListenerState extends State<GlobalRealtimeListener> {
  late final RealtimeService _realtime;
  final _audio = AudioPlayer();
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    _realtime = RealtimeService(widget.controller.api);
    _subscription = _realtime.messages.listen((message) {
      if (message['sender_id'] != widget.controller.user?['id']) {
        _audio.play(
          UrlSource('${widget.controller.api.baseUrl}/notification-sound'),
        );
      }
    });
    _realtime.connect(widget.controller.user!['id'] as int).catchError((_) {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _realtime.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
