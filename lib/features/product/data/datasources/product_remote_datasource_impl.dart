import '../../../../core/services/api_service.dart';
import 'product_remote_datasource.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiService apiService;

  ProductRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<dynamic>> getProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  }) async {
    return await apiService.getProducts(
      token,
      category: category,
      query: query,
      province: province,
      city: city,
      sellerId: sellerId,
    );
  }

  @override
  Future<List<dynamic>> getMyProducts(String token) async {
    return await apiService.getMyProducts(token);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await apiService.getCategories();
  }

  @override
  Future<void> createProduct(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  ) async {
    List<String> imageUrls = [];
    if (imagePaths.isNotEmpty) {
      imageUrls = await apiService.uploadImages(token, imagePaths);
    }
    data['image_url'] = imageUrls.isNotEmpty ? imageUrls[0] : '';
    data['images'] = imageUrls;

    await apiService.createProduct(token, data);
  }

  @override
  Future<void> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> data,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  ) async {
    List<String> imageUrls = [...existingImageUrls];
    if (newImagePaths.isNotEmpty) {
      final uploaded = await apiService.uploadImages(token, newImagePaths);
      imageUrls.addAll(uploaded);
    }
    data['image_url'] = imageUrls.isNotEmpty ? imageUrls[0] : '';
    data['images'] = imageUrls;

    await apiService.updateProduct(token, productId, data);
  }

  @override
  Future<void> deleteProduct(String token, int productId) async {
    await apiService.deleteProduct(token, productId);
  }
}
