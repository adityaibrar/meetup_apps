abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? publicKey,
    String? street,
    String? village,
    String? district,
    String? city,
    String? province,
  });
  Future<void> updatePublicKey(String token, String publicKey);
}
