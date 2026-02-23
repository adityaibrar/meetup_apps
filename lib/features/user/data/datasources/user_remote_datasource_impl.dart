import '../../../../core/services/api_service.dart';
import 'user_remote_datasource.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService apiService;

  UserRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> getUserProfile(String token, int userId) async {
    return await apiService.getUserProfile(token, userId);
  }

  @override
  Future<List<dynamic>> searchUsers(String token, String query) async {
    return await apiService.searchUsers(token, query);
  }

  @override
  Future<void> updatePublicKey(String token, String publicKey) async {
    await apiService.updatePublicKey(token, publicKey);
  }
}
