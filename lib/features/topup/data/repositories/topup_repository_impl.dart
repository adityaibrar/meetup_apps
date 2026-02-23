import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/topup_history.dart';
import '../../domain/repositories/topup_repository.dart';
import '../datasources/topup_remote_datasource.dart';

class TopUpRepositoryImpl implements TopUpRepository {
  final TopUpRemoteDataSource remoteDataSource;

  TopUpRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TopUpHistory>>> getTopUpHistory(
    String token,
  ) async {
    try {
      final remoteData = await remoteDataSource.getTopUpHistory(token);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
