import '../../../../core/services/api_service.dart';
import 'rating_remote_datasource.dart';

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final ApiService apiService;

  RatingRemoteDataSourceImpl({required this.apiService});

  @override
  Future<void> submitRating(
    String token,
    int targetUserId,
    int score,
    String review,
  ) async {
    await apiService.submitRating(token, targetUserId, score, review);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRatings(
    String token,
    int targetUserId,
  ) async {
    final list = await apiService.getUserRatings(token, targetUserId);
    return list.cast<Map<String, dynamic>>();
  }
}
