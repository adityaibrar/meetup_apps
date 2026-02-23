import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class DeleteChatUseCase {
  final ChatRepository repository;

  DeleteChatUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, int roomId) {
    return repository.deleteChat(token, roomId);
  }
}
