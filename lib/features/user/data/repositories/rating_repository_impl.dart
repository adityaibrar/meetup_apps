import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';
import '../models/rating_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitRating(
    String token,
    int ratedUserId,
    int score,
    String review,
  ) async {
    try {
      await remoteDataSource.submitRating(token, ratedUserId, score, review);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getUserRatings(
    String token,
    int ratedUserId,
  ) async {
    try {
      final list = await remoteDataSource.getUserRatings(token, ratedUserId);
      final models = list.map((json) => RatingModel.fromJson(json)).toList();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
