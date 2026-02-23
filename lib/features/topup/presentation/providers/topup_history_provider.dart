import 'package:flutter/material.dart';
import '../../domain/entities/topup_history.dart';
import '../../domain/usecases/get_topup_history_usecase.dart';

class TopUpHistoryProvider extends ChangeNotifier {
  final GetTopUpHistoryUseCase getTopUpHistoryUseCase;

  TopUpHistoryProvider({required this.getTopUpHistoryUseCase});

  List<TopUpHistory> _historyList = [];
  List<TopUpHistory> get historyList => _historyList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHistory(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getTopUpHistoryUseCase.call(token);
      result.fold(
        (failure) => _errorMessage = failure.message,
        (data) => _historyList = data,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
