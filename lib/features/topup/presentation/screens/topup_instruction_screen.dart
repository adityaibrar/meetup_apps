import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'payment_success_screen.dart';

/// Screen instruksi pembayaran dengan countdown timer.
class TopUpInstructionScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String selectedPayment;
  final int points;

  const TopUpInstructionScreen({
    super.key,
    required this.data,
    required this.selectedPayment,
    required this.points,
  });

  @override
  State<TopUpInstructionScreen> createState() => _TopUpInstructionScreenState();
}

class _TopUpInstructionScreenState extends State<TopUpInstructionScreen> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  final ApiService _apiService = ApiService();
  bool _isChecking = false;
  int _remainingSeconds = 300;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startCountdown();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        final orderId = widget.data['order_id'];
        final token = Provider.of<AuthProvider>(context, listen: false).token;
        if (orderId != null && token != null) {
          _apiService.cancelTopUp(token, orderId).catchError((_) {});
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Waktu pembayaran habis')),
          );
          Navigator.pop(context);
        }
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkStatus(),
    );
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    final orderId = widget.data['order_id'];
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (orderId == null || token == null) return;

    setState(() => _isChecking = true);
    try {
      final resp = await _apiService.checkTopUpStatus(token, orderId);
      final status = resp['status'];
      if (status == 'settlement' || status == 'capture') {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(points: widget.points),
            ),
          );
        }
      } else if (status == 'cancel' || status == 'expire' || status == 'deny') {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran dibatalkan')),
          );
          Navigator.pop(context);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isChecking = false);
  }

  String get _formattedTime {
    int m = _remainingSeconds ~/ 60;
    int s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isQris = widget.selectedPayment == 'qris';
    String paymentInfo = '';
    if (isQris && widget.data['actions'] != null) {
      final actions = widget.data['actions'] as List;
      if (actions.isNotEmpty) paymentInfo = actions[0]['url'];
    } else if (widget.data['va_numbers'] != null &&
        (widget.data['va_numbers'] as List).isNotEmpty) {
      paymentInfo = widget.data['va_numbers'][0]['va_number'];
    } else if (widget.data['bill_key'] != null) {
      paymentInfo =
          "${widget.data['biller_code']} - ${widget.data['bill_key']}";
    }

    String bankName = '';
    String instruction = '';
    switch (widget.selectedPayment) {
      case 'bca':
        bankName = 'BCA VA';
        instruction =
            '1. Buka m-BCA\n2. Pilih m-Transfer > BCA Virtual Account\n3. Masukkan No VA dan Konfirmasi.';
        break;
      case 'mandiri':
        bankName = 'Mandiri VA';
        instruction =
            '1. Buka Livin\' by Mandiri\n2. Pilih Bayar > Multi Payment\n3. Masukkan No VA.';
        break;
      case 'bni':
        bankName = 'BNI VA';
        instruction =
            '1. Buka BNI Mobile\n2. Pilih Transfer > Virtual Account\n3. Masukkan No VA.';
        break;
      case 'bri':
        bankName = 'BRI VA';
        instruction = '1. Buka BRImo\n2. Pilih BRIVA\n3. Masukkan No VA.';
        break;
      case 'qris':
        bankName = 'QRIS';
        instruction =
            '1. Screenshot QR Code\n2. Buka e-Wallet\n3. Scan/Bayar dari Galeri.';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(title: const Text('Instruksi Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bankName, style: AppTextStyles.h3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formattedTime,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Payment Info
            if (isQris && paymentInfo.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Image.network(
                  paymentInfo,
                  height: 220,
                  width: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, size: 60),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        paymentInfo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: paymentInfo));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nomor VA disalin!')),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Amount
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    'Rp ${widget.data['gross_amount']}',
                    style: AppTextStyles.price.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text('Cara Pembayaran', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                instruction,
                style: const TextStyle(height: 1.7, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),

            // Manual check
            OutlinedButton.icon(
              onPressed: _isChecking ? null : _checkStatus,
              icon: _isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Cek Status Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
