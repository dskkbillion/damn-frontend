import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // Needed for File type if using local file upload later

import 'package:http/http.dart' as http; // Assuming we might need this for SSE later, keep for context

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
  http.Client? _sseClient;
  StreamSubscription? _sseSubscription;

  AiChatRemoteDataSourceImpl(this._httpClient);

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
    const path = '/model/chat/list';
    try {
      final responseData = await _httpClient.get(
        path, 
        queryParameters: {'user_id': userId.toString()}
      );
      final data = _handleResponse(responseData);
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((convJson) => AiConversationModel.fromJson(convJson))
            .toList();
      } else {
        print('Warning: fetchConversations received unexpected format for GET. Data: $data');
        return [];
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in fetchConversations: $e');
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
    const path = '/model/chat/messages';
    // Use queryParameters for GET request
    final Map<String, String> queryParams = {
      'conversation_id': conversationId.toString(),
      'user_id': userId.toString(),
    };
    if (offset != null) queryParams['offset'] = offset.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    try {
      // Change from POST to GET
      final responseData = await _httpClient.get(path, queryParameters: queryParams);
      final data = _handleResponse(responseData);
      // API might return list directly in 'data' or nested under 'messages'
      // Keep checking both based on previous comments, but prefer 'messages' if specified by API doc
      if (data != null && data['messages'] is List) { 
        return (data['messages'] as List)
            .map((msgJson) => AiChatMessageModel.fromJson(msgJson))
            .toList();
      } else if (data != null && data is List) { // Fallback if data itself is the list
         return (data as List)
            .map((msgJson) => AiChatMessageModel.fromJson(msgJson))
            .toList();
      } else {
        print('Warning: loadHistory received unexpected format for $conversationId. Data: $data');
        return [];
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in loadHistory for $conversationId: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to load history for $conversationId: ${e.toString()}');
    }
  }

  @override
  Future<int> createConversation({
    required int userId,
    String? title,
  }) async {
    const path = '/model/chat/create';
    final Map<String, dynamic> requestData = {'user_id': userId};
    if (title != null) requestData['title'] = title;
    try {
      final responseData = await _httpClient.post(path, data: requestData);
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
      print('Unexpected error in createConversation: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  }) async {
    const path = '/model/chat/delete';
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    try {
      final responseData = await _httpClient.post(path, data: requestData);
      _handleResponse(responseData); // Throws if code != 200
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in deleteConversation for $conversationId: $e');
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
    // TODO: Implement actual SSE streaming via IHttpClient
    const path = '/model/chat';
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'message': message,
      'file_urls': fileUrls,
    };
    print('streamChatCompletion called (mock stream): path=$path, data=$requestData');
    // Return a mock stream for now
    return Stream.periodic(const Duration(milliseconds: 300), (i) => ' Mock Event $i')
               .take(5)
               .map((s) => jsonEncode({"chunk": s})) // Simulate JSON string event
               .asBroadcastStream();
  }

  @override
  Future<List<RelatedServiceModel>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
  }) async {
    const path = '/recsys/conversation/recommend';
    final Map<String, String> requestData = {
      'conversation_id': conversationId.toString(),
      'user_id': userId.toString(),
    };
    if (limit != null) requestData['limit'] = limit.toString();
    try {
      // Use GET request for recommendations
      final responseData = await _httpClient.get(path, queryParameters: requestData);
      final data = _handleResponse(responseData);
      if (data != null && data['items'] is List) {
        // Log the JSON object before parsing
        print('[DataSource] Parsing RelatedServiceModel items:');
        return (data['items'] as List).map((svcJson) {
           print('[DataSource] Item JSON: ${jsonEncode(svcJson)}'); // Log each item
           try {
             return RelatedServiceModel.fromJson(svcJson);
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
    } catch (e, stacktrace) {
      print('Unexpected error in getRelatedServices: $e\n$stacktrace');
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
    const path = '/chat/allocate';
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'item': item,
      'limit': limit,
      'similarity_threshold': similarityThreshold,
    };
    try {
      final responseData = await _httpClient.post(path, data: requestData);
      // Interface expects Map<String, dynamic>, so return the handled data directly
      return _handleResponse(responseData) as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e, stacktrace) {
      print('Unexpected error in allocateChatResource: $e\n$stacktrace');
      throw ds_exceptions.DataSourceException(message: 'Failed to allocate chat resource: ${e.toString()}');
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
    _sseSubscription?.cancel();
    _sseClient?.close();
    print("AiChatRemoteDataSource disposed.");
  }
} 