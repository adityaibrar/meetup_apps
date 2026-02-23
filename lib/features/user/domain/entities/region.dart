import 'package:equatable/equatable.dart';

/// Entity Region — pure Dart.
class Region extends Equatable {
  final String id;
  final String name;

  const Region({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
