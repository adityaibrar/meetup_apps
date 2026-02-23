import 'package:equatable/equatable.dart';

/// Entity Product — pure Dart.
class Product extends Equatable {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String? category;
  final String? condition;
  final String? imageUrl;
  final List<String>? images;
  final Map<String, dynamic>? seller;

  const Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.category,
    this.condition,
    this.imageUrl,
    this.images,
    this.seller,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    category,
    condition,
    imageUrl,
    images,
    seller,
  ];
}
