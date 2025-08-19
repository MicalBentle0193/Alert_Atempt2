import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';

class ApiService {
  final String serverBase;
  WebSocketChannel? _channel;
  Stream<dynamic>? _stream;

  ApiService({required this.serverBase});

  Future<List<WynfordAlert>> fetchActiveAlerts() async {
    final res = await http.get(Uri.parse('$serverBase/alerts'));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body) as List;
      return list.map((e) => WynfordAlert.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  Future<http.Response> createAlert(Map<String, dynamic> body, {required String adminPin}) {
    return http.post(
      Uri.parse('$serverBase/admin/create'),
      headers: {
        'Content-Type': 'application/json',
        'x-admin-pin': adminPin,
      },
      body: jsonEncode(body),
    );
  }

  /// Real-time websocket connection. Sends a subscribe message with zipCodes.
  void connectWebSocket(List<String> zipCodes, void Function(WynfordAlert) onAlert, {String path = '/ws'}) {
    disconnectWebSocket();
    _channel = WebSocketChannel.connect(Uri.parse(serverBase.replaceFirst('http', 'ws') + path));
    _stream = _channel!.stream;
    // send initial subscribe
    _channel!.sink.add(jsonEncode({'action': 'subscribe', 'zipCodes': zipCodes}));
    _stream!.listen((dynamic data) {
      try {
        final js = jsonDecode(data as String) as Map<String, dynamic>;
        if (js['kind'] == 'alert' && js['payload'] != null) {
          final alert = WynfordAlert.fromMap(js['payload'] as Map<String, dynamic>);
          onAlert(alert);
        }
      } catch (_) {}
    }, onDone: () {
      _channel = null;
    }, onError: (_) {
      _channel = null;
    });
  }

  void updateSubscription(List<String> zipCodes) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'action': 'subscribe', 'zipCodes': zipCodes}));
    }
  }

  void disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
    _stream = null;
  }
}
