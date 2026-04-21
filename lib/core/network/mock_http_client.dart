import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'i_http_client.dart';
import 'package:dio/dio.dart';

/// A mock implementation of IHttpClient for testing and development.
///
/// Returns predefined successful responses or throws exceptions based on the URL path.
// @Injectable(as: IHttpClient)
class MockHttpClient implements IHttpClient {

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    AppLogger.d('[MockHttpClient] GET: $path, Params: $queryParams');
    await Future.delayed(const Duration(milliseconds: 400)); // Slightly longer delay for recommendations

    if (path == '/model/chat/list') { 
      return {
        'code': 200,
        'message': 'Success',
        'data': {
          'items': [
             {'conversation_id': 1, 'title': 'Mock Conv 1 (Loaded)', 'created_at': '2024-03-30T10:00:00Z', 'updated_at': '2024-04-01T11:20:30Z'},
             {'conversation_id': 2, 'title': 'Mock Conv 2 (Loaded)', 'created_at': '2024-03-28T15:10:00Z', 'updated_at': '2024-03-29T09:05:10Z'},
             {'conversation_id': 3, 'title': 'API Patterns (Loaded)', 'created_at': '2024-04-02T08:00:00Z', 'updated_at': '2024-04-02T08:00:00Z'},
          ]
        }
      };
    } else if (path == '/model/chat/messages') {
        final convId = int.tryParse(queryParams?['conversation_id'] ?? '1') ?? 1;
        AppLogger.d('[MockHttpClient] GET history for conv: $convId');
        return {
           'code': 200,
           'message': 'Success',
           'data': {
             'messages': [
                {
                  'message_id': 'mock_msg_${convId}_1',
                  'conversation_id': convId,
                  'role': 'user',
                  'content': 'Mock message 1 for conversation $convId',
                  'files': [],
                  'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000
                },
                {
                  'message_id': 'mock_msg_${convId}_2',
                  'conversation_id': convId,
                  'role': 'assistant',
                  'content': 'Mock response 2 for conversation $convId. It can be a bit longer to test wrapping and scrolling behavior.',
                  'files': [],
                  'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000
                },
             ]
           }
        };
    // Removed /recsys/conversation/recommend mock data - using real API now
    } else if (path.contains('conversations')) {
      return {
        'data': [
          {'id': 'conv1', 'title': 'Mock Conversation 1', 'last_message_time': '2023-10-27T10:00:00Z'},
          {'id': 'conv2', 'title': 'Mock Conversation 2', 'last_message_time': '2023-10-26T15:30:00Z'},
        ]
      };
    } else if (path.contains('history')) {
      return {
        'data': [
           {'message_id': 'msg1', 'sender': 'user', 'content': 'Hello', 'timestamp': '2023-10-27T10:00:10Z'},
           {'message_id': 'msg2', 'sender': 'ai', 'content': 'Hi there!', 'timestamp': '2023-10-27T10:00:15Z'},
        ]
      };
    } else if (path.contains('related_services')) {
      return {'data': [{'service_id': 'svc1', 'name': 'Mock Service'}]};
    }
    return {'data': {}};
  }

  @override
  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    AppLogger.d('[MockHttpClient] POST: $path, Data: $body');
    await Future.delayed(const Duration(milliseconds: 500));

    // Match the expected path from the data source exactly
    if (path == '/model/chat/create') { 
        final newId = DateTime.now().millisecondsSinceEpoch % 1000; // Simple mock ID
        final title = body['title'] ?? 'New Mock Conversation $newId';
        AppLogger.d('[MockHttpClient] Creating conversation: $title');
        // Ensure the response includes code, message, and data with expected fields
        return {
          'code': 200, 
          'message': 'Conversation created successfully',
          'data': {
            'conversation_id': newId, // Use the key expected by the data source
            // Add other potential fields if the model expects them, otherwise keep it simple
            // 'title': title, 
            // 'created_at': DateTime.now().toIso8601String(),
            // 'updated_at': DateTime.now().toIso8601String(),
          }
        };
    } else if (path.contains('delete')) {
       // Ensure delete also has code/message for consistency if needed by handleResponse
       return {'code': 200, 'message': 'Deleted', 'data': {'success': true}};
    } else if (path.contains('transcribe') || path == '/model/chat/audio') { 
        AppLogger.d('[MockHttpClient] Transcribing audio...');
        // Ensure transcription response matches _handleResponse expectations
        return {'code': 200, 'message': 'Transcribed', 'data': {'content': 'This is the mock transcription result.'}};
    } else if (path.contains('/model/chat/messages')) { // Assuming history might be POST (though GET is better)
        final convId = body['conversation_id'] ?? 1; 
         AppLogger.d('[MockHttpClient] Fetching history via POST for conv: $convId');
        // Return structure matching the GET version
        return {
           'code': 200,
           'message': 'Success',
           'data': {
             'messages': [
                {'id': 10, 'conversation_id': convId, 'sender': 'user', 'content': 'What is a neural network?', 'created_at': '2024-04-01T11:20:35Z', 'file_urls': [], 'related_services': []},
                {'id': 11, 'conversation_id': convId, 'sender': 'assistant', 'content': 'A neural network is a series of algorithms...', 'created_at': '2024-04-01T11:21:05Z', 'file_urls': [], 'related_services': [{'id': 101, 'title': 'Intro to ML', 'url': 'http://example.com/ml'}]},
             ]
           }
         };
    // Removed /recsys/conversation/recommend POST mock data - using real API now
    } else if (path.contains('chat/allocate')) {
      AppLogger.d('[MockHttpClient] Simulating allocation action...');
      return {
        'code': 200,
        'message': 'Allocation successful',
        'data': {
          'allocated_service': {'id': 201, 'title': 'Allocated Mock Service', 'url': 'http://example.com/allocated'},
          'reason': 'High similarity match based on mock criteria.',
        }
      };
    }

    // Fallback for unhandled POST requests
    AppLogger.d('[MockHttpClient] POST $path - Unhandled, returning default success');
    return {'code': 200, 'message': 'Success (Unhandled Mock)', 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path,
    File file,
   {String fileField = 'file', 
    Map<String, String>? fields}
  ) async {
     AppLogger.d('[MockHttpClient] POST Multipart: $path, File: ${file.path}, Field: $fileField, Fields: $fields');
     await Future.delayed(const Duration(milliseconds: 800));

     // Simulate successful file upload
     if (path.contains('upload')) {
       final fileName = file.path.split(Platform.pathSeparator).last;
       return {
         'code': 200,
         'message': 'File uploaded successfully (Mock)',
         'data': {'file_url': 'https://mockstorage.com/$fileName'}
       };
     } 

     // Default success for other multipart requests in mock
     AppLogger.d('[MockHttpClient] POST Multipart $path - Unhandled, returning default success');
     return {
       'code': 200,
       'message': 'Mock multipart success (Unhandled)',
       'data': {'success': true} 
      };
  }

  @override
  Stream<String> postAndStream(String path, {Map<String, dynamic>? body}) {
    AppLogger.d('[MockHttpClient] postAndStream called for $path - Returning error stream');
    return Stream<String>.error(UnimplementedError('MockHttpClient.postAndStream not implemented'));
  }

  @override
  Dio getDioInstance() {
    return Dio();
  }

  @override
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    AppLogger.d('[MockHttpClient] PUT: $endpoint, Body: $body');
    await Future.delayed(const Duration(milliseconds: 300));
    return {'code': 200, 'message': 'Success (Unhandled Mock PUT)', 'data': {}};
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    AppLogger.d('[MockHttpClient] DELETE: $endpoint');
    await Future.delayed(const Duration(milliseconds: 300));
    return {'code': 200, 'message': 'Success (Unhandled Mock DELETE)', 'data': {}};
  }
} 