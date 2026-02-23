import '../../../../core/services/api_service.dart';
import 'chat_remote_datasource.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiService apiService;

  ChatRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<dynamic>> getMyChats(String token) async {
    return await apiService.getMyChats(token);
  }

  @override
  Future<Map<String, dynamic>> initPrivateChat(
    String token,
    int targetUserId,
  ) async {
    return await apiService.initPrivateChat(token, targetUserId);
  }

  @override
  Future<Map<String, dynamic>> getRoomStatus(String token, int roomId) async {
    return await apiService.getRoomStatus(token, roomId);
  }

  @override
  Future<void> toggleMeetupReady(String token, int roomId) async {
    await apiService.toggleMeetupReady(token, roomId);
  }

  @override
  Future<void> deleteChat(String token, int roomId) async {
    await apiService.deleteChat(token, roomId);
  }

  @override
  Future<Map<String, dynamic>> uploadChatMedia(
    String token,
    String filePath,
  ) async {
    return await apiService.uploadChatMedia(token, filePath);
  }
}
