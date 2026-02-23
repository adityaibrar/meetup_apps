import '../../../../core/services/api_service.dart';
import '../models/topup_history_model.dart';

abstract class TopUpRemoteDataSource {
  Future<List<TopUpHistoryModel>> getTopUpHistory(String token);
}

class TopUpRemoteDataSourceImpl implements TopUpRemoteDataSource {
  final ApiService apiService;

  TopUpRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<TopUpHistoryModel>> getTopUpHistory(String token) async {
    final rawData = await apiService.getTopUpHistory(token);
    return rawData.map((e) => TopUpHistoryModel.fromJson(e)).toList();
  }
}
