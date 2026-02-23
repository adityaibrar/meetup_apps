import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/user_repository.dart';

class UpdatePublicKeyUseCase {
  final UserRepository repository;

  UpdatePublicKeyUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, String publicKey) {
    return repository.updatePublicKey(token, publicKey);
  }
}
