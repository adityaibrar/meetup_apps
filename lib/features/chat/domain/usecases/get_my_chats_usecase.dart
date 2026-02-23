import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class GetMyChatsUseCase {
  final ChatRepository repository;

  GetMyChatsUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call(String token) {
    return repository.getMyChats(token);
  }
}
