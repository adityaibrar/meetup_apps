import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class UpdatePublicKeyUseCase {
  final AuthRepository repository;

  UpdatePublicKeyUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, String publicKey) {
    return repository.updatePublicKey(token, publicKey);
  }
}
