import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, int productId) {
    return repository.deleteProduct(token, productId);
  }
}
