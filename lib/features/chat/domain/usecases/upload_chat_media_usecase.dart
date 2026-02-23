import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class UploadChatMediaUseCase {
  final ChatRepository repository;

  UploadChatMediaUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String token,
    String filePath,
  ) async {
    return await repository.uploadChatMedia(token, filePath);
  }
}
