import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();
const adminPin = '4729'; // hardcoded admin PIN
final List<Map<String, dynamic>> _alerts = []; // in-memory store
final Map<WebSocket, List<String>> _clients = {};

void main(List<String> args) async {
  final router = Router();

  router.get('/alerts', (Request req) {
    return Response.ok(jsonEncode(_alerts));
  });

  router.post('/admin/create', (Request req) async {
    final pin = req.headers['x-admin-pin'];
    if (pin != adminPin) {
      return Response.forbidden('Invalid admin PIN');
    }
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    // ensure id
    final id = body['id'] as String? ?? _uuid.v4();
    body['id'] = id;
    body['issuedAt'] = body['issuedAt'] ?? DateTime.now().toIso8601String();
    body['active'] = body['active'] ?? true;
    // schedule send if sendAt provided
    if (body.containsKey('sendAt')) {
      final sendAt = DateTime.parse(body['sendAt'] as String);
      final now = DateTime.now();
      final delay = sendAt.isAfter(now) ? sendAt.difference(now) : Duration.zero;
      Timer(delay, () => _broadcastAlert(body));
    } else {
      _broadcastAlert(body);
    }
    // store historical
    _alerts.insert(0, body);
    return Response.ok(jsonEncode({'status': 'ok', 'id': id}));
  });

  // WebSocket endpoint
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) {
    if (request.url.path == 'ws') {
      return webSocketHandler(_wsHandler)(request);
    } else {
      return router(request);
    }
  });

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server started at http://${server.address.host}:${server.port}');
}

FutureOr<void> _wsHandler(WebSocket webSocket) {
  print('Client connected');
  webSocket.listen((dynamic msg) {
    try {
      final m = jsonDecode(msg as String) as Map<String, dynamic>;
      if (m['action'] == 'subscribe') {
        final zips = (m['zipCodes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        _clients[webSocket] = zips;
        print('Subscribed zips: $zips');
      }
    } catch (_) {}
  }, onDone: () {
    _clients.remove(webSocket);
    print('Client disconnected');
  });
}

void _broadcastAlert(Map<String, dynamic> alert) {
  // send to connected clients whose zip intersects
  final targetZips = (alert['zipCodes'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{};
  final payload = jsonEncode({'kind': 'alert', 'payload': alert});
  _clients.forEach((ws, zips) {
    if (zips.any((z) => targetZips.contains(z))) {
      try {
        ws.add(payload);
      } catch (_) {}
    }
  });
  // also print to console for admin monitoring
  print('Broadcasted alert ${alert['id']} to zips: ${alert['zipCodes']}');
}
