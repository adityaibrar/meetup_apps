import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.id,
    required super.raterId,
    required super.ratedUserId,
    required super.score,
    required super.review,
    required super.createdAt,
    super.rater,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      raterId: json['rater_id'],
      ratedUserId: json['rated_user_id'],
      score: json['score'],
      review: json['review'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      rater: json['rater'] != null ? UserModel.fromJson(json['rater']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rater_id': raterId,
    'rated_user_id': ratedUserId,
    'score': score,
    'review': review,
    'created_at': createdAt.toIso8601String(),
    'rater': rater != null ? (rater as UserModel).toJson() : null,
  };
}
