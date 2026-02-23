import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String token, int userId) {
    return repository.getUserProfile(token, userId);
  }
}
