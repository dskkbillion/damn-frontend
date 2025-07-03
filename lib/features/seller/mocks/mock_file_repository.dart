import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_file_repository.dart';
import 'package:dartz/dartz.dart';

class MockFileRepository extends Mock implements IFileRepository {
  @override
  Future<Either<Failure, List<String>>> uploadMultipleFiles(List<String> filePaths, String type) async {
    return Right(['https://example.com/mock-image-1.jpg', 'https://example.com/mock-image-2.jpg']);
  }
  
  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    return Right('https://example.com/mock-file.jpg');
  }
  
  @override
  Future<Either<Failure, String>> getTemporaryUrl(String fileUri) async {
    return Right('https://cdn.example.com/temporary-access-url.jpg');
  }
} 