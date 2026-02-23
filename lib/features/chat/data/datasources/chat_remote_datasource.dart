abstract class ChatRemoteDataSource {
  Future<List<dynamic>> getMyChats(String token);
  Future<Map<String, dynamic>> initPrivateChat(String token, int targetUserId);
  Future<Map<String, dynamic>> getRoomStatus(String token, int roomId);
  Future<void> toggleMeetupReady(String token, int roomId);
  Future<void> deleteChat(String token, int roomId);
}
