import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getMyChats(String token) async {
    try {
      final data = await remoteDataSource.getMyChats(token);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> initPrivateChat(
    String token,
    int targetUserId,
  ) async {
    try {
      final data = await remoteDataSource.initPrivateChat(token, targetUserId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRoomStatus(
    String token,
    int roomId,
  ) async {
    try {
      final data = await remoteDataSource.getRoomStatus(token, roomId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMeetupReady(
    String token,
    int roomId,
  ) async {
    try {
      await remoteDataSource.toggleMeetupReady(token, roomId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String token, int roomId) async {
    try {
      await remoteDataSource.deleteChat(token, roomId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadChatMedia(
    String token,
    String filePath,
  ) async {
    try {
      final result = await remoteDataSource.uploadChatMedia(token, filePath);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
