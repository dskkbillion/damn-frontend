import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

abstract class IFileRepository {
  /// Uploads a file and returns the URL upon success.
  Future<Either<Failure, String>> uploadFile(File file);
} 