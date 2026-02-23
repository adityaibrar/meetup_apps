import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/config/app_config.dart';

/// Service WebSocket untuk real-time messaging.
class SocketService {
  String get wsUrl => AppConfig.wsUrl;
  WebSocketChannel? _channel;
  bool _isReady = false;
  final List<Map<String, dynamic>> _pendingMessages = [];

  bool get isReady => _isReady;
  bool get isSocketOpen => _channel != null;

  void connect(
    String token,
    Function(dynamic) onMessage,
    Function() onDisconnect, {
    Function()? onConnected,
  }) {
    try {
      final uri = Uri.parse('$wsUrl?token=$token');
      _channel = WebSocketChannel.connect(uri);
      _isReady = false;

      _channel!.stream.listen(
        (message) {
          if (!_isReady) {
            _isReady = true;
            log('WebSocket Connection Ready');
            for (final msg in _pendingMessages) {
              _channel!.sink.add(jsonEncode(msg));
            }
            _pendingMessages.clear();
            onConnected?.call();
          }

          try {
            final messageStr = message.toString();
            final parts = messageStr.split('}{');
            for (int i = 0; i < parts.length; i++) {
              String jsonStr = parts[i];
              if (i > 0) jsonStr = '{$jsonStr';
              if (i < parts.length - 1) jsonStr = '$jsonStr}';
              try {
                final decoded = jsonDecode(jsonStr);
                onMessage(decoded);
              } catch (e) {
                log('Error parsing individual JSON: $e');
              }
            }
          } catch (e) {
            log('Error handling message: $e');
          }
        },
        onDone: () {
          log('WebSocket Disconnected');
          _isReady = false;
          _channel = null;
          onDisconnect();
        },
        onError: (error) {
          log('WebSocket Error: $error');
          _isReady = false;
          _channel = null;
          onDisconnect();
        },
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_channel != null && !_isReady) {
          _isReady = true;
          log('WebSocket Ready (timeout)');
          for (final msg in _pendingMessages) {
            _channel!.sink.add(jsonEncode(msg));
          }
          _pendingMessages.clear();
          onConnected?.call();
        }
      });
    } catch (e) {
      log("Connection Error: $e");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _isReady = false;
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      if (_isReady) {
        _channel!.sink.add(jsonEncode(message));
      } else {
        _pendingMessages.add(message);
      }
    }
  }
}
