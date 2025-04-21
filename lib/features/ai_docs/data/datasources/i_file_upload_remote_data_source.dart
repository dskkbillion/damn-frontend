// Placeholder interface for IFileUploadRemoteDataSource
// This file is created to resolve build errors caused by missing imports.

import 'dart:io';

abstract class IFileUploadRemoteDataSource {
  // Define methods based on how FileUploadRepositoryImpl uses it, or leave empty for now
  Future<String> uploadFile(File file, {String? path}); // Example method signature
} 