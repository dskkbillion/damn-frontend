import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // Needed for File type if using local file upload later

import 'package:http/http.dart' as http; // Assuming we might need this for SSE later, keep for context
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

import '../../../../core/network/i_http_client.dart';
import '../../../../core/error/failures.dart';
// import '../../../../core/error/exceptions.dart'; // Using DataSource specific exceptions
import '../models/ai_conversation_model.dart';
import '../models/ai_chat_message_model.dart';
import '../models/related_service_model.dart';
// import '../models/chat_allocation_result_model.dart'; // Not directly used in return types
import 'i_ai_chat_remote_data_source.dart';
import 'exceptions.dart' as ds_exceptions;

/// {@template ai_chat_remote_data_source_impl}
/// Implementation of [IAiChatRemoteDataSource] that uses an [IHttpClient]
/// to interact with the backend API.
/// {@endtemplate}
@LazySingleton(as: IAiChatRemoteDataSource)
class AiChatRemoteDataSourceImpl implements IAiChatRemoteDataSource {
  final IHttpClient _httpClient;
  // Remove unused http client and subscription from here, handled in HttpClient layer
  // http.Client? _sseClient;
  // StreamSubscription? _sseSubscription;

  AiChatRemoteDataSourceImpl(this._httpClient);

  // Helper to get base URL, providing a fallback
  String _getModelBaseUrl() {
     return dotenv.env['MODEL_BASE_URL'] ?? 'http://default-model-url/api';
  }

  // Helper to extract data or throw ServerException
  dynamic _handleResponse(Map<String, dynamic> responseData) {
    final int code = responseData['code'] ?? 500;
    final String message = responseData['message'] ?? 'Unknown server error';
    if (code == 200) {
      return responseData['data'];
    } else {
      throw ds_exceptions.ServerException(message: message, statusCode: code);
    }
  }

  @override
  Future<List<AiConversationModel>> fetchConversations({required int userId}) async {
    const String path = '/model/chat/list';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Fetching conversations from: $fullUrl");
    try {
      final responseData = await _httpClient.post(
        fullUrl, // Use full URL
        body: {'user_id': userId}
      );
      final data = _handleResponse(responseData);
      if (data != null && data['conversations'] is List) {
        return (data['conversations'] as List)
            .map((convJson) => AiConversationModel.fromJson(convJson))
            .toList();
      } else {
        print('Warning: fetchConversations (POST) received unexpected format. Data: $data');
        return [];
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in fetchConversations at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to fetch conversations: ${e.toString()}');
    }
  }

  @override
  Future<List<AiChatMessageModel>> loadHistory({
    required int conversationId,
    required int userId,
    int? offset,
    int? limit,
  }) async {
    const String path = '/model/chat/messages';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Loading history from: $fullUrl for conv $conversationId");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    if (offset != null) requestData['offset'] = offset;
    if (limit != null) requestData['limit'] = limit;

    try {
      final responseData = await _httpClient.post(fullUrl, data: requestData);
      final data = _handleResponse(responseData);
      
      if (data != null && data is List) { 
        print("[DATASOURCE DEBUG] Parsing ${data.length} messages from root data list.");
        return (data as List).map((msgJson) {
          print("[DATASOURCE DEBUG] Parsing msgJson: ${jsonEncode(msgJson)}");
           if (msgJson is Map<String, dynamic>) { 
             print("[DATASOURCE DEBUG]  -> id type: ${msgJson['id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> message_id type: ${msgJson['message_id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> conversation_id type: ${msgJson['conversation_id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> role type: ${msgJson['role']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> content type: ${msgJson['content']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> files type: ${msgJson['files']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> timestamp type: ${msgJson['timestamp']?.runtimeType}");
           }
           try {
              return AiChatMessageModel.fromJson(msgJson as Map<String, dynamic>);
           } catch (e, stacktrace) {
              print("[DATASOURCE ERROR] Failed to parse msgJson: $e");
              print("[DATASOURCE ERROR] Stacktrace: $stacktrace");
              print("[DATASOURCE ERROR] Failing msgJson: ${jsonEncode(msgJson)}");
              rethrow;
           }
        }).toList();
      } else if (data != null && data['messages'] is List) {
        print("[DATASOURCE DEBUG] Parsing ${ (data['messages'] as List).length} messages from nested 'messages' key.");
        return (data['messages'] as List).map((msgJson) {
           print("[DATASOURCE DEBUG] Parsing msgJson: ${jsonEncode(msgJson)}"); 
          if (msgJson is Map<String, dynamic>) { 
             print("[DATASOURCE DEBUG]  -> id type: ${msgJson['id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> message_id type: ${msgJson['message_id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> conversation_id type: ${msgJson['conversation_id']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> role type: ${msgJson['role']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> content type: ${msgJson['content']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> files type: ${msgJson['files']?.runtimeType}");
             print("[DATASOURCE DEBUG]  -> timestamp type: ${msgJson['timestamp']?.runtimeType}");
          }
          try {
            return AiChatMessageModel.fromJson(msgJson as Map<String, dynamic>); 
          } catch (e, stacktrace) {
            print("[DATASOURCE ERROR] Failed to parse msgJson: $e");
            print("[DATASOURCE ERROR] Stacktrace: $stacktrace");
            print("[DATASOURCE ERROR] Failing msgJson: ${jsonEncode(msgJson)}");
            rethrow; 
          }
        }).toList();
      } else {
        print('Warning: loadHistory received unexpected format for $conversationId. Data: $data');
        return [];
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in loadHistory for $conversationId at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to load history for $conversationId: ${e.toString()}');
    }
  }

  @override
  Future<int> createConversation({
    required int userId,
    String? title,
  }) async {
    const String path = '/model/chat/create';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Creating conversation at: $fullUrl");
    final Map<String, dynamic> requestData = {'user_id': userId};
    if (title != null) requestData['title'] = title;
    try {
      final responseData = await _httpClient.post(fullUrl, data: requestData);
      final data = _handleResponse(responseData);
      if (data != null && data['conversation_id'] is int) {
        return data['conversation_id'];
      } else {
        throw ds_exceptions.DataSourceException(message: 'Invalid conversation ID format in API response');
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in createConversation at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/delete';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Deleting conversation $conversationId at: $fullUrl");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    try {
      final responseData = await _httpClient.post(fullUrl, data: requestData);
      _handleResponse(responseData); // Throws if code != 200
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in deleteConversation for $conversationId at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to delete conversation $conversationId: ${e.toString()}');
    }
  }

  @override
  Stream<String> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
  }) {
    const String path = '/model/chat';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Streaming chat completion from: $fullUrl");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'message': message,
      // Only include 'files' if not empty, assuming API expects this
      if (fileUrls.isNotEmpty) 'files': fileUrls, 
    };
    print('[DataSource] Calling streamChatCompletion with data: $requestData to $fullUrl');

    try {
      // Call the HttpClient method that returns the raw SSE stream
      final rawSseStream = _httpClient.postAndStream(fullUrl, data: requestData);

      // Transform the raw stream to extract relevant data chunks
      // Using StreamTransformer for cleaner separation of parsing logic
      return rawSseStream.transform(StreamTransformer.fromHandlers(
        handleData: (rawData, sink) {
          // Process raw SSE data which might contain multiple events
          final lines = rawData.split('\n');
          String? currentEvent;
          String currentData = '';

          for (final line in lines) {
            if (line.startsWith('event:')) {
              currentEvent = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              // Append data, removing the 'data:' prefix
              // Handle potential multi-line data if needed (though unlikely here)
              currentData += line.substring(5).trim(); 
            } else if (line.trim().isEmpty) {
              // Empty line signifies end of an event
              if (currentEvent == 'conversation.reasoning.delta' && currentData.isNotEmpty) {
                try {
                  final jsonData = jsonDecode(currentData);
                  if (jsonData is Map<String, dynamic> && jsonData.containsKey('reason_content')) {
                    final contentChunk = jsonData['reason_content'] as String?;
                    if (contentChunk != null && contentChunk.isNotEmpty) {
                      print('[DataSource - SSE Parser] Yielding chunk: $contentChunk');
                      sink.add(contentChunk); // Add the extracted content chunk to the output stream
                    }
                  }
                } catch (e) {
                  print('[DataSource - SSE Parser] Error decoding data JSON: $e. Data: $currentData');
                  // Decide how to handle JSON decode error (e.g., addError to sink)
                   sink.addError(ds_exceptions.DataSourceException(message: "Failed to parse SSE data chunk: $e"));
                }
              }
              // Reset for the next event
              currentEvent = null;
              currentData = '';
            }
             // Ignore other lines (like comments starting with ':')
          }
        },
        handleError: (error, stackTrace, sink) {
          print('[DataSource - SSE Stream] Error from HttpClient stream: $error');
          // Forward the error to the output stream
           if (error is ds_exceptions.ServerException) {
              sink.addError(error); // Forward ServerException
           } else {
              sink.addError(ds_exceptions.NetworkException(message: "Network error during stream: ${error.toString()}"));
           }
        },
        handleDone: (sink) {
          print('[DataSource - SSE Stream] HttpClient stream done.');
          sink.close(); // Close the output stream when the input stream is done
        },
      ));
    } catch (e) {
       // Catch errors during the initial call to postAndStream (e.g., network unavailable before request)
       print("Error initiating streamChatCompletion to $fullUrl: $e");
       // Return a stream that immediately emits an error
        if (e is ds_exceptions.ServerException || e is ds_exceptions.NetworkException) {
          return Stream.error(e);
        } else {
           return Stream.error(ds_exceptions.DataSourceException(message: "Failed to initiate SSE stream: ${e.toString()}"));
        }
    }
  }

  @override
  Future<List<RelatedServiceModel>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
  }) async {
    const String path = '/model/chat/related_services';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Fetching related services from: $fullUrl");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    if (limit != null) requestData['limit'] = limit;
    try {
      final responseData = await _httpClient.post(fullUrl, data: requestData);
      final data = _handleResponse(responseData);
      if (data != null && data['services'] is List) {
        return (data['services'] as List).map((serviceJson) {
           print('[DataSource] Item JSON: ${jsonEncode(serviceJson)}'); // Log each item
           try {
             return RelatedServiceModel.fromJson(serviceJson);
           } catch (e, stacktrace) {
              print('[DataSource] Error parsing item JSON: $e');
              print(stacktrace); 
              // Optionally return a default/error model or rethrow
              // For now, let it potentially fail to surface the issue
              rethrow; // Rethrow to see the original error source
           }
         }).toList();
      } else {
        print('Warning: getRelatedServices received unexpected format. Data: $data');
        return [];
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in getRelatedServices at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to get related services: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item,
    required int limit,
    required double similarityThreshold,
  }) async {
    const String path = '/model/chat/allocate';
    final String fullUrl = _getModelBaseUrl() + path;
    print("Allocating resource at: $fullUrl");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'item': item,
      'limit': limit,
      'similarity_threshold': similarityThreshold,
    };
    try {
      final responseData = await _httpClient.post(fullUrl, data: requestData);
      return _handleResponse(responseData) as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in allocateChatResource at $fullUrl: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to allocate resource: ${e.toString()}');
    }
  }

  @override
  Future<String> transcribeAudio({
    required String audioOssUrl,
    int? userId,
  }) async {
    const path = '/model/chat/audio';
    final Map<String, dynamic> requestData = {
      'url': audioOssUrl,
    };
    if (userId != null) requestData['user_id'] = userId;
    try {
      // This method likely needs POST, not multipart if sending URL
      final responseData = await _httpClient.post(path, data: requestData); 
      final data = _handleResponse(responseData);
      if (data != null && data['content'] is String) {
        return data['content'];
      } else {
        throw ds_exceptions.DataSourceException(message: 'Invalid transcription format in API response');
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in transcribeAudio: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to transcribe audio: ${e.toString()}');
    }
  }

  // Dispose method if needed (e.g., to close SSE client)
  void dispose() {
    // _sseSubscription?.cancel();
    // _sseClient?.close();
    print("AiChatRemoteDataSource disposed.");
  }
} 