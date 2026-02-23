import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

class AuthResult {
  final User user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login(String email, String password);
  Future<Either<Failure, AuthResult>> register({
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
  });
  Future<Either<Failure, void>> updatePublicKey(String token, String publicKey);
}
