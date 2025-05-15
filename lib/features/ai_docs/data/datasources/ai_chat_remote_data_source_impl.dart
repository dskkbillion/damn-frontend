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
import 'package:dio/dio.dart';

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
  dynamic _handleResponse(dynamic responseData) {
    // 处理Dio直接响应的格式
    if (responseData is Response) {
      responseData = responseData.data;
    }
    
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
    print("Fetching conversations using path: $path");
    try {
      final responseData = await _httpClient.post(
        path,
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
      print('Unexpected error in fetchConversations at $path: $e');
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
    print("Loading history using path: $path for conv $conversationId");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    if (offset != null) requestData['offset'] = offset;
    if (limit != null) requestData['limit'] = limit;

    try {
      final responseData = await _httpClient.post(path, body: requestData);
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
      print('Unexpected error in loadHistory for $conversationId at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to load history for $conversationId: ${e.toString()}');
    }
  }

  @override
  Future<int> createConversation({
    required int userId,
    String? title,
  }) async {
    const String path = '/model/chat/create';
    print("Creating conversation using path: $path");
    final Map<String, dynamic> requestData = {'user_id': userId};
    if (title != null) requestData['title'] = title;
    try {
      final responseData = await _httpClient.post(path, body: requestData);
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
      print('Unexpected error in createConversation at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/delete';
    print("Deleting conversation $conversationId using path: $path");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    try {
      final responseData = await _httpClient.post(path, body: requestData);
      _handleResponse(responseData); // Throws if code != 200
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in deleteConversation for $conversationId at $path: $e');
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
    print("Streaming chat completion using path: $path");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'message': message,
      // Only include 'files' if not empty, assuming API expects this
      if (fileUrls.isNotEmpty) 'files': fileUrls, 
    };
    print('[DataSource] Calling streamChatCompletion with data: $requestData');

    try {
      // Call the HttpClient method that returns the raw SSE stream
      final rawSseStream = _httpClient.postAndStream(path, body: requestData);

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
              if ((currentEvent == 'conversation.reasoning.delta' || 
                  currentEvent == 'conversation.message.delta') && 
                  currentData.isNotEmpty) {
                try {
                  final jsonData = jsonDecode(currentData);
                  if (jsonData is Map<String, dynamic>) {
                    // 检查并提取内容，支持多种字段名称
                    String? contentChunk;
                    if (jsonData.containsKey('reason_content')) {
                      contentChunk = jsonData['reason_content'] as String?;
                    } else if (jsonData.containsKey('content')) {
                      contentChunk = jsonData['content'] as String?;
                    }
                    
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
              } else if (currentEvent == 'conversation.message.completed' && currentData.isNotEmpty) {
                print('[DataSource - SSE Parser] Received completion event');
                try {
                  final jsonData = jsonDecode(currentData);
                  // 在这里可以处理最终消息内容，但我们不需要再发送，因为我们已经累积了所有增量更新
                  // 这只是一个标记完成的事件
                } catch (e) {
                  print('[DataSource - SSE Parser] Error decoding completion JSON: $e');
                }
              } else if (currentEvent == 'done') {
                print('[DataSource - SSE Parser] Received done event');
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
       print("Error initiating streamChatCompletion to $path: $e");
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
    int? messageId,
  }) async {
    const String path = '/recsys/conversation/recommend';
    print("Fetching related services using path: $path");
    
    Map<String, dynamic> requestData = {
      'user_id': userId,
    };
    
    if (conversationId > 0) {
      requestData['conversation_id'] = conversationId;
      
      if (messageId != null) {
        requestData['message_id'] = messageId;
      } else {
        requestData['message_id'] = 5;
      }
    }
    
    if (limit != null) {
      requestData['limit'] = limit;
    } else {
      requestData['limit'] = 10;
    }
    
    try {
      final responseData = await _httpClient.post(path, body: requestData);
      final data = _handleResponse(responseData);
      
      print('[DataSource] Related services response: ${jsonEncode(data)}');
      
      if (data != null && data['items'] is List) {
        return (data['items'] as List).map((serviceJson) {
           print('[DataSource] Item JSON: ${jsonEncode(serviceJson)}');
           try {
             return RelatedServiceModel(
               id: serviceJson['id'] as int? ?? 0,
               title: serviceJson['name'] as String? ?? 'Unknown service',
               imageUrl: serviceJson['mainImage'] as String? ?? '',
               price: (serviceJson['price'] as num?)?.toDouble() ?? 0.0,
             );
           } catch (e, stacktrace) {
              print('[DataSource] Error parsing item JSON: $e');
              print(stacktrace); 
              rethrow;
           }
         }).toList();
      } else if (data != null && data['services'] is List) {
        return (data['services'] as List).map((serviceJson) {
           print('[DataSource] Service JSON: ${jsonEncode(serviceJson)}');
           try {
             return RelatedServiceModel.fromJson(serviceJson);
           } catch (e, stacktrace) {
              print('[DataSource] Error parsing service JSON: $e');
              print(stacktrace); 
              rethrow;
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
      print('Unexpected error in getRelatedServices at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to get related services: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item,
    required int merchantId,
  }) async {
    const String path = '/model/chat/allocate';
    print("Allocating resource using path: $path");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'item': item,
      'merchant_id': merchantId,
    };
    
    try {
      // 创建一个带有更长超时设置的请求选项
      final options = Options(
        // 设置更长的超时时间（60秒接收超时）
        receiveTimeout: const Duration(seconds: 60),
      );
      
      print("使用60秒超时发起allocate请求");
      
      // 使用带选项的post方法发送请求
      final response = await _httpClient.getDioInstance().post(path, 
        data: requestData,
        options: options,
      );
      
      return _handleResponse(response) as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in allocateChatResource at $path: $e');
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
      final responseData = await _httpClient.post(path, body: requestData); 
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