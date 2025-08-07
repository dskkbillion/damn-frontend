import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';

void main() {
  group('SuccessCase Entity Tests', () {
    test('should create SuccessCase with default pending status', () {
      final successCase = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: '',
        title: 'Test Case',
        description: 'Test Description',
        createTime: DateTime.now(),
      );

      expect(successCase.uploadStatus, SuccessCaseUploadStatus.pending);
      expect(successCase.uploadProgress, 0);
      expect(successCase.needsUpload, true);
      expect(successCase.canRetry, false);
    });

    test('should correctly identify upload states', () {
      final uploadingCase = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: '',
        title: 'Test',
        description: 'Test',
        createTime: DateTime.now(),
        uploadStatus: SuccessCaseUploadStatus.uploading,
        uploadProgress: 50,
      );

      expect(uploadingCase.isUploading, true);
      expect(uploadingCase.isCompleted, false);
      expect(uploadingCase.needsUpload, false);
      expect(uploadingCase.canRetry, false);
    });

    test('should allow retry for failed uploads', () {
      final failedCase = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: '',
        title: 'Test',
        description: 'Test',
        createTime: DateTime.now(),
        uploadStatus: SuccessCaseUploadStatus.failed,
        errorMessage: 'Upload failed',
      );

      expect(failedCase.canRetry, true);
      expect(failedCase.isCompleted, false);
      expect(failedCase.needsUpload, false);
    });

    test('should correctly identify completed uploads', () {
      final completedCase = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: 'https://example.com/image.jpg',
        title: 'Test',
        description: 'Test',
        createTime: DateTime.now(),
        uploadStatus: SuccessCaseUploadStatus.completed,
      );

      expect(completedCase.isCompleted, true);
      expect(completedCase.needsUpload, false);
      expect(completedCase.canRetry, false);
    });

    test('copyWith should create new instance with updated values', () {
      final original = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: '',
        title: 'Original',
        description: 'Original Description',
        createTime: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        title: 'Updated',
        imageUrl: 'https://example.com/image.jpg',
        uploadStatus: SuccessCaseUploadStatus.completed,
      );

      expect(updated.title, 'Updated');
      expect(updated.imageUrl, 'https://example.com/image.jpg');
      expect(updated.uploadStatus, SuccessCaseUploadStatus.completed);
      
      // Original should remain unchanged
      expect(original.title, 'Original');
      expect(original.imageUrl, '');
      expect(original.uploadStatus, SuccessCaseUploadStatus.pending);
    });

    test('should correctly convert to/from JSON', () {
      final successCase = SuccessCase(
        id: '1',
        imagePath: '/path/to/image.jpg',
        imageUrl: 'https://example.com/image.jpg',
        title: 'Test Case',
        description: 'Test Description',
        createTime: DateTime(2024, 1, 1),
        uploadStatus: SuccessCaseUploadStatus.completed,
        uploadProgress: 100,
      );

      final json = successCase.toJson();
      expect(json['id'], '1');
      expect(json['imagePath'], '/path/to/image.jpg');
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['title'], 'Test Case');
      expect(json['description'], 'Test Description');
      expect(json['uploadStatus'], 'completed');
      expect(json['uploadProgress'], 100);

      final fromJson = SuccessCase.fromJson(json);
      expect(fromJson.id, successCase.id);
      expect(fromJson.imagePath, successCase.imagePath);
      expect(fromJson.imageUrl, successCase.imageUrl);
      expect(fromJson.title, successCase.title);
      expect(fromJson.uploadStatus, successCase.uploadStatus);
    });
  });

  group('SuccessCaseUploadStatus Tests', () {
    test('should have correct enum values', () {
      expect(SuccessCaseUploadStatus.values.length, 4);
      expect(SuccessCaseUploadStatus.values.contains(SuccessCaseUploadStatus.pending), true);
      expect(SuccessCaseUploadStatus.values.contains(SuccessCaseUploadStatus.uploading), true);
      expect(SuccessCaseUploadStatus.values.contains(SuccessCaseUploadStatus.completed), true);
      expect(SuccessCaseUploadStatus.values.contains(SuccessCaseUploadStatus.failed), true);
    });

    test('should convert to string correctly', () {
      expect(SuccessCaseUploadStatus.pending.toString(), 
             'SuccessCaseUploadStatus.pending');
      expect(SuccessCaseUploadStatus.uploading.toString(), 
             'SuccessCaseUploadStatus.uploading');
      expect(SuccessCaseUploadStatus.completed.toString(), 
             'SuccessCaseUploadStatus.completed');
      expect(SuccessCaseUploadStatus.failed.toString(), 
             'SuccessCaseUploadStatus.failed');
    });
  });
}