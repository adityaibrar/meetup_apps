import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getProducts(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  }) async {
    try {
      final data = await remoteDataSource.getProducts(
        token,
        category: category,
        query: query,
        province: province,
        city: city,
        sellerId: sellerId,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMyProducts(String token) async {
    try {
      final data = await remoteDataSource.getMyProducts(token);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories() async {
    try {
      final data = await remoteDataSource.getCategories();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> createProduct(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  ) async {
    try {
      await remoteDataSource.createProduct(token, data, imagePaths);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> data,
    List<String> newImagePaths,
    List<String> existingImageUrls,
  ) async {
    try {
      await remoteDataSource.updateProduct(
        token,
        productId,
        data,
        newImagePaths,
        existingImageUrls,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(
    String token,
    int productId,
  ) async {
    try {
      await remoteDataSource.deleteProduct(token, productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
