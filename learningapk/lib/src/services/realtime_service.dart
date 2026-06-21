import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_service.dart';

class RealtimeService {
  RealtimeService(this.api);

  final ApiService api;
  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _subscription;
  final _messages = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<void> connect(int userId) async {
    await disconnect();
    final response = await api.get('/realtime/config');
    final config = Map<String, dynamic>.from(response['data'] as Map);
    final scheme = config['scheme'] == 'wss' ? 'wss' : 'ws';
    final uri = Uri.parse(
      '$scheme://${config['host']}:${config['port']}/app/${config['app_key']}'
      '?protocol=7&client=flutter&version=1.0&flash=false',
    );
    _socket = WebSocketChannel.connect(uri);
    _subscription = _socket!.stream.listen(
      (raw) => _handleEvent(raw.toString(), userId),
      onError: (_) {},
    );
  }

  Future<void> _handleEvent(String raw, int userId) async {
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final event = envelope['event']?.toString();
    final rawData = envelope['data'];
    final data = rawData is String
        ? jsonDecode(rawData) as Map<String, dynamic>
        : Map<String, dynamic>.from(rawData as Map? ?? {});

    if (event == 'pusher:connection_established') {
      final socketId = data['socket_id'].toString();
      final channel = 'private-chat.$userId';
      final auth = await api.postForm('/broadcasting/auth', {
        'socket_id': socketId,
        'channel_name': channel,
      });
      _socket?.sink.add(
        jsonEncode({
          'event': 'pusher:subscribe',
          'data': {'auth': auth['auth'], 'channel': channel},
        }),
      );
      return;
    }

    if (event == 'chat.message' && data['message'] is Map) {
      _messages.add(Map<String, dynamic>.from(data['message'] as Map));
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _socket?.sink.close();
    _subscription = null;
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messages.close();
  }
}
