import '../../../../core/services/api_service.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await apiService.login(email, password);
  }

  @override
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
  }) async {
    final response = await apiService.register(
      username,
      email,
      password,
      fullName,
      publicKey: publicKey,
      street: street,
      village: village,
      district: district,
      city: city,
      province: province,
    );
    return response;
  }

  @override
  Future<void> updatePublicKey(String token, String publicKey) async {
    await apiService.updatePublicKey(token, publicKey);
  }
}
