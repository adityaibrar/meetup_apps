import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call(
    String token, {
    String? category,
    String? query,
    String? province,
    String? city,
    int? sellerId,
  }) {
    return repository.getProducts(
      token,
      category: category,
      query: query,
      province: province,
      city: city,
      sellerId: sellerId,
    );
  }
}
