abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> getUserProfile(String token, int userId);
  Future<List<dynamic>> searchUsers(String token, String query);
  Future<void> updatePublicKey(String token, String publicKey);
}
