import '../../domain/entities/user.dart';

/// Model User dengan serialization — extends entity User.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.imageUrl,
    required super.points,
    super.address,
    super.fullName,
    super.city,
    super.province,
    super.averageRating = 0.0,
    super.totalReviews = 0,
    super.tier = 'bronze',
    super.isTrusted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['image_url'],
      points: json['points'] ?? 0,
      address: json['address'],
      fullName: json['full_name'],
      city: json['city'],
      province: json['province'],
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString()) ?? 0.0
          : 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      tier: json['tier'] ?? 'bronze',
      isTrusted: json['is_trusted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'image_url': imageUrl,
    'points': points,
    'address': address,
    'full_name': fullName,
    'city': city,
    'province': province,
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'tier': tier,
    'is_trusted': isTrusted,
  };
}
