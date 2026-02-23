import '../../domain/entities/region.dart';

/// Model Region dengan serialization.
class RegionModel extends Region {
  const RegionModel({required super.id, required super.name});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(id: json['id'].toString(), name: json['name'] ?? '');
  }
}
