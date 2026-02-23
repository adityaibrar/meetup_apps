import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<Either<Failure, void>> submitRating(
    String token,
    int ratedUserId,
    int score,
    String review,
  );
  Future<Either<Failure, List<RatingEntity>>> getUserRatings(
    String token,
    int ratedUserId,
  );
}
