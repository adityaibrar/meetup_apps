import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<dynamic>>> getMyChats(String token);
  Future<Either<Failure, Map<String, dynamic>>> initPrivateChat(
    String token,
    int targetUserId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getRoomStatus(
    String token,
    int roomId,
  );
  Future<Either<Failure, void>> toggleMeetupReady(String token, int roomId);
  Future<Either<Failure, void>> deleteChat(String token, int roomId);
}
