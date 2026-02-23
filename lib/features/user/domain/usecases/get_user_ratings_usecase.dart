import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rating_entity.dart';
import '../repositories/rating_repository.dart';

class GetUserRatingsUseCase {
  final RatingRepository repository;

  GetUserRatingsUseCase(this.repository);

  Future<Either<Failure, List<RatingEntity>>> call(
    String token,
    int ratedUserId,
  ) async {
    return await repository.getUserRatings(token, ratedUserId);
  }
}
