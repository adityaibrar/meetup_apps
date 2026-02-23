import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthResult>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final token = response['token'] as String;
      final user = UserModel.fromJson(response['user']);
      return Right(AuthResult(user: user, token: token));
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
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
  }) async {
    try {
      final response = await remoteDataSource.register(
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
      final token = response['token'] as String;
      final user = UserModel.fromJson(response['user']);
      return Right(AuthResult(user: user, token: token));
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
