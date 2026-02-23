import '../repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResult>> call({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? publicKey,
    String? street,
    String? village,
    String? district,
    String? city,
    String? province,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
      publicKey: publicKey,
      street: street,
      village: village,
      district: district,
      city: city,
      province: province,
    );
  }
}
