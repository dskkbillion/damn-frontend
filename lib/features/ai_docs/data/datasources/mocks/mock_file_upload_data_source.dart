import 'dart:async';
import 'dart:io';

import '../i_file_upload_data_source.dart';

/// Mock implementation of [IFileUploadDataSource] for testing and preview.
class MockFileUploadDataSource implements IFileUploadDataSource {
  Future<void> _simulateDelay([int milliseconds = 300]) =>
      Future.delayed(Duration(milliseconds: milliseconds));

  bool _shouldFail = false;

  /// Sets whether the mock data source should simulate failures.
  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  @override
  Future<String> uploadFile(File file) async {
    await _simulateDelay(800); // Simulate upload time

    if (_shouldFail) {
      throw Exception('Mock Upload Error: Failed to upload ${file.path}');
    }

    // Simulate generating a fake OSS URL
    final fileName = file.path.split(Platform.pathSeparator).last;
    final mockOssUrl = 'mock-oss://bucket-name/uploads/$fileName'; 
    print('Mock: Uploaded ${file.path} to $mockOssUrl');

    return mockOssUrl;
  }
}
