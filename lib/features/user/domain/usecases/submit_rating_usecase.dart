import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/rating_repository.dart';

class SubmitRatingUseCase {
  final RatingRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String token,
    SubmitRatingParams params,
  ) async {
    return await repository.submitRating(
      token,
      params.ratedUserId,
      params.score,
      params.review,
    );
  }
}

class SubmitRatingParams extends Equatable {
  final int ratedUserId;
  final int score;
  final String review;

  const SubmitRatingParams({
    required this.ratedUserId,
    required this.score,
    required this.review,
  });

  @override
  List<Object> get props => [ratedUserId, score, review];
}
