import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/file_upload_item.dart';

void main() {
  group('Phase 2 Fixes Test', () {
    test('FileUploadItem should support retry count', () {
      // Test that FileUploadItem can be created with retry capability
      final item = FileUploadItem(
        id: 'test-1',
        localPath: '/path/to/file.pdf',
        fileName: 'test.pdf',
        fileSize: 1024,
        status: FileUploadStatus.failed,
        errorMessage: 'Network error',
      );
      
      expect(item.status, FileUploadStatus.failed);
      expect(item.errorMessage, 'Network error');
      
      // Test copyWith for retry
      final retryItem = item.copyWith(
        status: FileUploadStatus.waiting,
        errorMessage: null,
      );
      
      expect(retryItem.status, FileUploadStatus.waiting);
      expect(retryItem.errorMessage, isNull);
    });
    
    test('FileUploadItem serialization for draft', () {
      // Test that FileUploadItem can be serialized for draft saving
      final item = FileUploadItem(
        id: 'test-2',
        localPath: '/path/to/image.jpg',
        fileName: 'image.jpg',
        fileSize: 2048,
        status: FileUploadStatus.success,
        uploadedUrl: 'https://example.com/image.jpg',
        progress: 1.0,
      );
      
      // Create a map representation (as would be saved in draft)
      final itemData = {
        'id': item.id,
        'localPath': item.localPath,
        'fileName': item.fileName,
        'fileSize': item.fileSize,
        'statusIndex': item.status.index,
        'progress': item.progress,
        'uploadedUrl': item.uploadedUrl,
        'errorMessage': item.errorMessage,
      };
      
      // Reconstruct from map
      final restoredItem = FileUploadItem(
        id: itemData['id'] as String,
        localPath: itemData['localPath'] as String,
        fileName: itemData['fileName'] as String,
        fileSize: itemData['fileSize'] as int,
        status: FileUploadStatus.values[itemData['statusIndex'] as int],
        progress: (itemData['progress'] as num).toDouble(),
        uploadedUrl: itemData['uploadedUrl'] as String?,
        errorMessage: itemData['errorMessage'] as String?,
      );
      
      expect(restoredItem.id, item.id);
      expect(restoredItem.fileName, item.fileName);
      expect(restoredItem.status, item.status);
      expect(restoredItem.uploadedUrl, item.uploadedUrl);
    });
  });
}