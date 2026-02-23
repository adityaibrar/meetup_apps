import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Service HTTP utama untuk semua API calls ke backend.
/// Dipecah per-feature datasource yang mendelegasikan ke sini.
class ApiService {
  String get baseUrl => AppConfig.baseUrl;

  // ── Auth ──
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Login gagal');
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String fullName, {
    String? publicKey,
    String? street,
    String? village,
    String? district,
    String? city,
    String? province,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'public_key': publicKey,
        'street': street,
        'village': village,
        'district': district,
        'city': city,
        'province': province,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registrasi gagal');
    }
    return jsonDecode(response.body);
  }

  // ── Chat ──
  Future<Map<String, dynamic>> initPrivateChat(
    String token,
    int targetUserId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/private'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'target_user_id': targetUserId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Gagal memulai chat');
  }

  Future<Map<String, dynamic>> getRoomStatus(String token, int roomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/room/$roomId/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Gagal mendapat status room');
  }

  Future<void> toggleMeetupReady(String token, int roomId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/toggle-ready'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'room_id': roomId}),
    );
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal toggle ready');
    }
  }

  Future<List<dynamic>> getMyChats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/rooms'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    throw Exception('Gagal memuat daftar chat');
  }

  Future<void> deleteChat(String token, int roomId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/chat/room/$roomId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Gagal menghapus chat');
  }

  // ── User ──
  Future<Map<String, dynamic>> getUserProfile(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Gagal memuat profil user');
  }

  Future<List<dynamic>> searchUsers(String token, String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Gagal mencari user');
  }

  Future<void> updatePublicKey(String token, String publicKey) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/update-key'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'public_key': publicKey}),
    );
    if (response.statusCode != 200) throw Exception('Gagal update public key');
  }

  // ── Top Up ──
  Future<Map<String, dynamic>> createTopUpCharge(
    String token,
    int points,
    String paymentType,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topup/charge'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'points': points, 'payment_type': paymentType}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Gagal membuat charge: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> checkTopUpStatus(
    String token,
    String orderId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/topup/status/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Gagal cek status');
  }

  Future<void> cancelTopUp(String token, String orderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/topup/cancel/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal membatalkan transaksi');
    }
  }

  Future<List<dynamic>> getTopUpHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/topup/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Gagal memuat riwayat top-up');
  }

  // ── Products ──
  Future<List<dynamic>> getProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  }) async {
    String url = '$baseUrl/products?';
    if (category != null) url += 'category=$category&';
    if (query != null) url += 'q=$query&';
    if (province != null) url += 'province=$province&';
    if (city != null) url += 'city=$city&';
    if (sellerId != null) url += 'seller_id=$sellerId&';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Gagal memuat produk');
  }

  Future<List<dynamic>> getMyProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Gagal memuat produk saya');
  }

  Future<dynamic> createProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(productData),
    );
    if (response.statusCode == 201) return json.decode(response.body);
    throw Exception('Gagal membuat produk');
  }

  Future<String> uploadImage(String token, String filePath) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['url'];
    }
    throw Exception('Gagal upload gambar');
  }

  Future<List<String>> uploadImages(
    String token,
    List<String> filePaths,
  ) async {
    var uri = Uri.parse('$baseUrl/upload/multiple');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Authorization': 'Bearer $token'});
    for (var path in filePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', path));
    }
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return List<String>.from(jsonResponse['urls']);
    }
    throw Exception('Gagal upload gambar');
  }

  Future<void> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(productData),
    );
    if (response.statusCode != 200) throw Exception('Gagal update produk');
  }

  Future<void> deleteProduct(String token, int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Gagal menghapus produk');
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal memuat kategori');
  }
}
