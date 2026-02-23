import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../../chat/data/datasources/encryption_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_public_key_usecase.dart';

/// Provider untuk state management Authentication menggunakan Clean Architecture.
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final UpdatePublicKeyUseCase _updatePublicKeyUseCase;
  final EncryptionService _encryptionService;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required UpdatePublicKeyUseCase updatePublicKeyUseCase,
    required EncryptionService encryptionService,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _updatePublicKeyUseCase = updatePublicKeyUseCase,
       _encryptionService = encryptionService;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  /// Login user → init encryption → sync public key ke server.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _loginUseCase.call(email, password);

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (authResult) async {
        _token = authResult.token;
        _user = authResult.user as UserModel;

        // Init enkripsi (load/generate RSA keys)
        await _encryptionService.init();

        // Sync public key ke server
        if (_encryptionService.publicKey != null) {
          await _updatePublicKeyUseCase.call(
            _token!,
            _encryptionService.publicKey!,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Register user baru → generate keys → panggil API register.
  Future<bool> register(
    String username,
    String email,
    String password,
    String fullName, {
    String? street,
    String? village,
    String? district,
    String? city,
    String? province,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _encryptionService.init();

    final result = await _registerUseCase.call(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
      publicKey: _encryptionService.publicKey,
      street: street,
      village: village,
      district: district,
      city: city,
      province: province,
    );

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (authResult) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  void logout() {
    _token = null;
    _user = null;
    _encryptionService.clearKeys();
    notifyListeners();
  }
}
