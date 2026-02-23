import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<dynamic>>> getProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  });

  Future<Either<Failure, List<dynamic>>> getMyProducts(String token);

  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories();

  Future<Either<Failure, void>> createProduct(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  );

  Future<Either<Failure, void>> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> data,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  );

  Future<Either<Failure, void>> deleteProduct(String token, int productId);
}
