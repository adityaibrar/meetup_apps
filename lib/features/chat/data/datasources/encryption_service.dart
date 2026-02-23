import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

/// Service untuk enkripsi/dekripsi RSA (E2E Encryption).
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _storage = const FlutterSecureStorage();
  String? _publicKey;
  String? _privateKey;

  String? get publicKey => _publicKey;

  Future<void> init() async {
    _publicKey = await _storage.read(key: 'public_key');
    _privateKey = await _storage.read(key: 'private_key');

    if (_publicKey == null || _privateKey == null) {
      log('No keys found. Generating new key pair...');
      await generateKeys();
    } else {
      log('Keys loaded from secure storage.');
    }
  }

  Future<void> generateKeys() async {
    try {
      var result = await RSA.generate(2048);
      _publicKey = result.publicKey;
      _privateKey = result.privateKey;
      await _storage.write(key: 'public_key', value: _publicKey);
      await _storage.write(key: 'private_key', value: _privateKey);
      log('Keys generated and saved.');
    } catch (e) {
      log('Error generating keys: $e');
    }
  }

  Future<void> clearKeys() async {
    await _storage.delete(key: 'public_key');
    await _storage.delete(key: 'private_key');
    _publicKey = null;
    _privateKey = null;
  }

  Future<String> encrypt(String plainText, String publicKey) async {
    try {
      return await RSA.encryptOAEP(plainText, '', Hash.SHA256, publicKey);
    } catch (e) {
      log('Error encrypting: $e');
      throw Exception('Encryption failed');
    }
  }

  Future<String> decrypt(String encryptedText) async {
    if (_privateKey == null) throw Exception('Private key not found');
    try {
      return await RSA.decryptOAEP(
        encryptedText,
        '',
        Hash.SHA256,
        _privateKey!,
      );
    } catch (e) {
      log('Error decrypting: $e');
      return encryptedText;
    }
  }
}
