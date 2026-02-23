import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/topup_history.dart';

abstract class TopUpRepository {
  Future<Either<Failure, List<TopUpHistory>>> getTopUpHistory(String token);
}
