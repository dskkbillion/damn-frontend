import 'dart:io'; // Required for File type

/// {@template i_file_upload_data_source}
/// Interface for remote data operations related to file uploading.
/// {@endtemplate}
abstract class IFileUploadDataSource {
  
  /// Uploads a file to the backend.
  /// 
  /// Takes a local [File] object.
  /// Returns the final URL of the uploaded file (e.g., OSS URL) on success.
  /// Throws specific exceptions (e.g., ServerException, NetworkException) on failure.
  Future<String> uploadFile(File file);
} 