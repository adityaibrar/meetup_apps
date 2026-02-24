import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

/// Provider untuk state management Top Up.
class TopUpProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  int? _selectedPoints;
  String? _selectedPayment;
  bool _isLoading = false;
  bool _isChecking = false;
  String? _error;

  int? get selectedPoints => _selectedPoints;
  String? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;
  String? get error => _error;

  List<Map<String, dynamic>> packages = [];
  bool _isLoadingPackages = false;
  bool get isLoadingPackages => _isLoadingPackages;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'bca',
      'name': 'BCA Virtual Account',
      'icon': Icons.account_balance,
      'color': Color(0xFF1565C0),
    },
    {
      'id': 'mandiri',
      'name': 'Mandiri Virtual Account',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFFF9A825),
    },
    {
      'id': 'bni',
      'name': 'BNI Virtual Account',
      'icon': Icons.credit_card,
      'color': Color(0xFFEF6C00),
    },
    {
      'id': 'bri',
      'name': 'BRI Virtual Account',
      'icon': Icons.account_balance,
      'color': Color(0xFF0D47A1),
    },
    {
      'id': 'qris',
      'name': 'QRIS (Gopay, OVO, Dana)',
      'icon': Icons.qr_code_2,
      'color': Color(0xFFE91E63),
    },
  ];

  void selectPoints(int points) {
    _selectedPoints = points;
    notifyListeners();
  }

  void selectPayment(String paymentId) {
    _selectedPayment = paymentId;
    notifyListeners();
  }

  Future<void> fetchPackages() async {
    _isLoadingPackages = true;
    _error = null;
    notifyListeners();

    try {
      packages = await _apiService.getTopupPackages();
      _isLoadingPackages = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPackages = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Buat charge top up ke Midtrans.
  Future<Map<String, dynamic>?> processTopUp(String token) async {
    if (_selectedPoints == null || _selectedPayment == null) {
      _error = 'Pilih paket dan metode pembayaran';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String paymentType = _selectedPayment!;
      if (paymentType == 'mandiri') paymentType = 'echannel';

      final response = await _apiService.createTopUpCharge(
        token,
        _selectedPoints!,
        paymentType,
      );
      _isLoading = false;
      notifyListeners();
      return response['data'];
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cek status pembayaran.
  Future<String?> checkStatus(String token, String orderId) async {
    if (_isChecking) return null;
    _isChecking = true;
    notifyListeners();

    try {
      final statusResp = await _apiService.checkTopUpStatus(token, orderId);
      _isChecking = false;
      notifyListeners();
      return statusResp['status'];
    } catch (e) {
      _isChecking = false;
      notifyListeners();
      return null;
    }
  }

  /// Batalkan transaksi.
  Future<void> cancelTopUp(String token, String orderId) async {
    try {
      await _apiService.cancelTopUp(token, orderId);
    } catch (_) {}
  }

  void reset() {
    _selectedPoints = null;
    _selectedPayment = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
