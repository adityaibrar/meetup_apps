import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class ToggleMeetupReadyUseCase {
  final ChatRepository repository;

  ToggleMeetupReadyUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, int roomId) {
    return repository.toggleMeetupReady(token, roomId);
  }
}
