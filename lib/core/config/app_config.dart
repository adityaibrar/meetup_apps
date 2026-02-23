import 'dart:io';
import 'package:flutter/foundation.dart';

/// Konfigurasi jaringan untuk koneksi ke backend server.
/// Ganti _localIP sesuai IP LAN komputer yang menjalankan backend.
class AppConfig {
  // ⚠️ Ganti dengan IP LAN komputer Anda
  static const String _localIP = "192.168.203.178"; //rs
  // static const String _localIP = "192.168.1.7"; //home

  static String get baseUrl => "http://$_host:8000/api";
  static String get wsUrl => "ws://$_host:8000/ws";

  static String get _host {
    if (kIsWeb) return "localhost";
    if (Platform.isAndroid) {
      return _localIP == "127.0.0.1" ? "10.0.2.2" : _localIP;
    }
    return _localIP;
  }

  /// Default email untuk auto-fill di login (development only)
  static String get mail {
    if (kIsWeb) return "user1@example.com";
    if (Platform.isIOS) {
      return _localIP == "127.0.0.1"
          ? "user1@example.com"
          : "user2@example.com";
    }
    return "user1@example.com";
  }
}
