abstract class ProductRemoteDataSource {
  Future<List<dynamic>> getProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  });

  Future<List<dynamic>> getMyProducts(String token);

  Future<List<Map<String, dynamic>>> getCategories();

  Future<void> createProduct(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  );

  Future<void> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> data,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  );

  Future<void> deleteProduct(String token, int productId);
}
