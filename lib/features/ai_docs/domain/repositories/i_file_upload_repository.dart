import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// {@template i_file_upload_repository}
/// Interface for the file upload repository.
/// Abstracts the data source details for uploading files.
/// {@endtemplate}
abstract class IFileUploadRepository {
  
  /// Uploads a file.
  ///
  /// Takes a local [File] object.
  /// Returns [Either<Failure, String>] where String is the uploaded file URL.
  Future<Either<Failure, String>> uploadFile(File file);
} 