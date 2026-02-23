import 'package:equatable/equatable.dart';

/// Base class untuk error handling yang terstruktur di seluruh app.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error cache lokal']);
}
