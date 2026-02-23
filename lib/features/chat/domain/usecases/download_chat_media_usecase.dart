import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/config/app_config.dart';

class DownloadChatMediaUseCase {
  Future<Either<Failure, String>> call(String mediaUrl) async {
    try {
      final baseUrl = AppConfig.baseUrl.replaceAll('/api', '');
      final fullUrl = '$baseUrl$mediaUrl';

      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode != 200) {
        return Left(ServerFailure('Gagal mengunduh media'));
      }

      final directory = await getApplicationDocumentsDirectory();
      final filename = mediaUrl.split('/').last;

      final chatMediaDir = Directory('${directory.path}/meetup_chat_media');
      if (!await chatMediaDir.exists()) {
        await chatMediaDir.create(recursive: true);
      }

      final filePath = '${chatMediaDir.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return Right(filePath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
