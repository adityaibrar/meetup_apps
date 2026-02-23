import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/region.dart';
import '../models/region_model.dart';

/// Service untuk mengambil data region Indonesia.
class RegionService {
  static const String baseUrl = 'https://api-regional-indonesia.vercel.app/api';

  Future<List<Region>> getProvinces() async {
    final response = await http.get(Uri.parse('$baseUrl/provinces'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => RegionModel.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat provinsi');
  }

  Future<List<Region>> getRegencies(String provinceId) async {
    final response = await http.get(Uri.parse('$baseUrl/cities/$provinceId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => RegionModel.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat kota/kabupaten');
  }

  Future<List<Region>> getDistricts(String regencyId) async {
    final response = await http.get(Uri.parse('$baseUrl/districts/$regencyId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => RegionModel.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat kecamatan');
  }

  Future<List<Region>> getVillages(String districtId) async {
    final response = await http.get(Uri.parse('$baseUrl/villages/$districtId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => RegionModel.fromJson(json)).toList();
    }
    throw Exception('Gagal memuat kelurahan/desa');
  }
}
