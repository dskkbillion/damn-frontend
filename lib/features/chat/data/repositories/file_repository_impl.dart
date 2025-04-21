import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_file_repository.dart';

// Correct import for Interface using package path
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_file_remote_data_source.dart';
// import 'package:dskk_flutter_refactor/core/platform/network_info.dart'; // Import if checking network status

class FileRepositoryImpl implements IFileRepository {
  final IFileRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Add if checking network status

  FileRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    // TODO: Check network connection using networkInfo if available

    try {
      final fileUrl = await remoteDataSource.uploadFile(file);
      return Right(fileUrl);
    } on ServerException catch (e) {
      // FIX: Use correct ServerFailure constructor
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString())); // Pass statusCode as string code
    } catch (e) {
      // FIX: Use correct GeneralFailure constructor (no message)
      print("Unexpected error in uploadFile Repository: $e");
      return Left(GeneralFailure());
    }
  }
} 