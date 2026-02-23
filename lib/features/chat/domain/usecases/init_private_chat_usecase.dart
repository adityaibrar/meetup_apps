import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class InitPrivateChatUseCase {
  final ChatRepository repository;

  InitPrivateChatUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String token,
    int targetUserId,
  ) {
    return repository.initPrivateChat(token, targetUserId);
  }
}
