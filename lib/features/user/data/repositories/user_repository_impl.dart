import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile(
    String token,
    int userId,
  ) async {
    try {
      final data = await remoteDataSource.getUserProfile(token, userId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> searchUsers(
    String token,
    String query,
  ) async {
    try {
      final data = await remoteDataSource.searchUsers(token, query);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> updatePublicKey(
    String token,
    String publicKey,
  ) async {
    try {
      await remoteDataSource.updatePublicKey(token, publicKey);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
