import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetMyProductsUseCase {
  final ProductRepository repository;

  GetMyProductsUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call(String token) {
    return repository.getMyProducts(token);
  }
}
