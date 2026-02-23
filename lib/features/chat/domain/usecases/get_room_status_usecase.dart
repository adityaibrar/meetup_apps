import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class GetRoomStatusUseCase {
  final ChatRepository repository;

  GetRoomStatusUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String token, int roomId) {
    return repository.getRoomStatus(token, roomId);
  }
}
