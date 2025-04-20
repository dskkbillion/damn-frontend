import 'dart:io';

abstract class IFileRemoteDataSource {
  Future<String> uploadFile(File file); // Returns file URL
} 