import 'package:equatable/equatable.dart';

/// Entity User — pure Dart, tanpa dependensi luar.
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String? imageUrl;
  final int points;
  final String? address;
  final String? fullName;
  final String? city;
  final String? province;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.imageUrl,
    required this.points,
    this.address,
    this.fullName,
    this.city,
    this.province,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    imageUrl,
    points,
    address,
    fullName,
    city,
    province,
  ];
}
