abstract class RatingRemoteDataSource {
  Future<void> submitRating(
    String token,
    int targetUserId,
    int score,
    String review,
  );
  Future<List<Map<String, dynamic>>> getUserRatings(
    String token,
    int targetUserId,
  );
}
