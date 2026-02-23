import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

class RatingEntity extends Equatable {
  final int id;
  final int raterId;
  final int ratedUserId;
  final int score;
  final String review;
  final DateTime createdAt;
  final User? rater;

  const RatingEntity({
    required this.id,
    required this.raterId,
    required this.ratedUserId,
    required this.score,
    required this.review,
    required this.createdAt,
    this.rater,
  });

  @override
  List<Object?> get props => [
    id,
    raterId,
    ratedUserId,
    score,
    review,
    createdAt,
    rater,
  ];
}
