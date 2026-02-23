import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';

class SearchUsersUseCase {
  final UserRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call(String token, String query) {
    return repository.searchUsers(token, query);
  }
}
