import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String token,
    Map<String, dynamic> data,
    List<String> imagePaths,
  ) {
    return repository.createProduct(token, data, imagePaths);
  }
}
