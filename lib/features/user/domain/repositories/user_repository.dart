import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile(
    String token,
    int userId,
  );
  Future<Either<Failure, List<dynamic>>> searchUsers(
    String token,
    String query,
  );
  Future<Either<Failure, void>> updatePublicKey(String token, String publicKey);
}
