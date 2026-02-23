import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/topup_history.dart';
import '../repositories/topup_repository.dart';

class GetTopUpHistoryUseCase {
  final TopUpRepository repository;

  GetTopUpHistoryUseCase(this.repository);

  Future<Either<Failure, List<TopUpHistory>>> call(String token) async {
    return await repository.getTopUpHistory(token);
  }
}
