import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // Needed for File type if using local file upload later

import 'package:http/http.dart' as http; // Assuming we might need this for SSE later, keep for context
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 添加FlutterSecureStorage导入

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
      // 获取token - 添加手动获取token的代码
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 获取到token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token，不添加Bearer前缀
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例，带上认证头
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: {'user_id': userId},
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 加载历史记录，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 创建会话，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 删除会话，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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
    
    // 构建请求数据，支持新的 image_urls 参数
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'message': message,
      'stream': true, // 确保启用流式响应
    };
    
    // 支持多模态：判断是否为图像URL并使用相应的参数名
    if (fileUrls.isNotEmpty) {
      // 简单的图像URL判断逻辑（可以根据实际需求调整）
      final isImageUrls = fileUrls.any((url) => 
        url.toLowerCase().contains('.jpg') || 
        url.toLowerCase().contains('.jpeg') || 
        url.toLowerCase().contains('.png') || 
        url.toLowerCase().contains('.gif') || 
        url.toLowerCase().contains('.webp') ||
        url.toLowerCase().contains('image') ||
        url.toLowerCase().contains('img'));
      
      if (isImageUrls) {
        requestData['image_urls'] = fileUrls; // 使用新的 image_urls 参数
        print('[DataSource] Adding image_urls: $fileUrls');
      } else {
        requestData['files'] = fileUrls; // 保持向后兼容（用于其他文件类型）
        print('[DataSource] Adding files: $fileUrls');
      }
    }
    
    print('[DataSource] Calling streamChatCompletion with data: $requestData');

    try {
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = storage.read(key: 'auth_token').then((token) {
        print("[AiDocs] 流式聊天，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
        
        // 创建完整的URL
        final String baseUrl = _getModelBaseUrl();
        String fullUrl = baseUrl.endsWith('/') ? baseUrl + path.substring(1) : baseUrl + path;
        if (!fullUrl.startsWith('http')) {
          fullUrl = 'http://' + fullUrl;
        }
        print("[AiDocs] 完整URL: $fullUrl");
        
        // 创建HTTP请求
        final request = http.Request('POST', Uri.parse(fullUrl));
        request.headers['Content-Type'] = 'application/json';
        
        // 添加认证头
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = token; // 直接使用token
        }
        print("[AiDocs] SSE请求头: ${request.headers}");
        
        // 添加请求体
        request.body = jsonEncode(requestData);
        
        // 发送请求并获取流式响应
        return http.Client().send(request).then((streamedResponse) {
          if (streamedResponse.statusCode == 200) {
            // 处理流式响应，支持新的事件类型
            return streamedResponse.stream
              .transform(utf8.decoder)
              .transform(StreamTransformer.fromHandlers(
                handleData: (String data, EventSink<String> sink) {
                  _processSSEData(data, sink);
                },
                handleError: (error, stackTrace, sink) {
                  print('[DataSource - SSE Stream] Error: $error');
                  sink.addError(ds_exceptions.NetworkException(
                    message: "Network error during stream: ${error.toString()}"
                  ));
                },
                handleDone: (sink) {
                  print('[DataSource - SSE Stream] Stream completed.');
                  sink.close();
                },
              ));
          } else {
            // 处理错误状态码
            throw ds_exceptions.ServerException(
              message: 'Failed to stream chat: ${streamedResponse.statusCode}',
              statusCode: streamedResponse.statusCode
            );
          }
        });
      });
      
      // 返回处理结果流
      return Stream.fromFuture(token).asyncExpand((value) => value);
      
    } catch (e) {
      // 处理错误
      print("Error initiating streamChatCompletion to $path: $e");
      if (e is ds_exceptions.ServerException || e is ds_exceptions.NetworkException) {
        return Stream.error(e);
      } else {
        return Stream.error(ds_exceptions.DataSourceException(
          message: "Failed to initiate SSE stream: ${e.toString()}"
        ));
      }
    }
  }

  // 新增：处理SSE数据的方法，支持更多事件类型
  void _processSSEData(String data, EventSink<String> sink) {
    final lines = data.split('\n');
    String? currentEvent;
    String currentData = '';

    for (final line in lines) {
      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        currentData += line.substring(5).trim();
      } else if (line.trim().isEmpty && currentEvent != null) {
        // 处理不同类型的SSE事件
        _handleSSEEvent(currentEvent, currentData, sink);
        
        // 重置状态
        currentEvent = null;
        currentData = '';
      }
    }
  }

  // 新增：处理不同类型的SSE事件
  void _handleSSEEvent(String event, String data, EventSink<String> sink) {
    try {
      switch (event) {
        case 'conversation.message.delta':
        case 'conversation.reasoning.delta':
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            if (jsonData is Map<String, dynamic>) {
              String? contentChunk;
              // 支持多种内容字段名称
              if (jsonData.containsKey('reason_content')) {
                contentChunk = jsonData['reason_content'] as String?;
              } else if (jsonData.containsKey('content')) {
                contentChunk = jsonData['content'] as String?;
              }
              
              if (contentChunk != null && contentChunk.isNotEmpty) {
                print('[DataSource - SSE] Content chunk: $contentChunk');
                sink.add(contentChunk);
              }
            }
          }
          break;
          
        case 'conversation.message.completed':
          print('[DataSource - SSE] Message completed');
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            print('[DataSource - SSE] Completion data: $jsonData');
          }
          // 发送特殊标记表示消息完成
          sink.add('[COMPLETED]');
          break;
          
        case 'conversation.message.cancelled':
          print('[DataSource - SSE] Message cancelled by user');
          sink.add('[CANCELLED]');
          break;
          
        case 'conversation.message.error':
          print('[DataSource - SSE] Message error');
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            final errorMsg = jsonData['error'] ?? 'Unknown error';
            sink.addError(ds_exceptions.ServerException(message: errorMsg));
          }
          break;
          
        case 'done':
          print('[DataSource - SSE] Stream done');
          sink.add('[DONE]');
          break;
          
        default:
          print('[DataSource - SSE] Unknown event type: $event');
          break;
      }
    } catch (e) {
      print('[DataSource - SSE] Error processing event $event: $e. Data: $data');
      sink.addError(ds_exceptions.DataSourceException(
        message: "Failed to parse SSE event: $e"
      ));
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 获取相关服务，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 分发资源，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头和更长超时设置的请求选项
      final options = Options(
        // 设置更长的超时时间（60秒接收超时）
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      
      print("[AiDocs] 请求头: ${options.headers}");
      print("使用60秒超时发起allocate请求");
      
      // 使用带选项的post方法发送请求
      final response = await _httpClient.getDioInstance().post(path, 
        data: requestData,
        options: options,
      );
      
      return _handleResponse(response.data) as Map<String, dynamic>;
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
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 转录音频，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      print("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
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

  @override
  Future<void> cancelChatGeneration({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/cancel';
    print("Cancelling chat generation for conversation $conversationId");
    
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    
    try {
      // 获取token
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print("[AiDocs] 取消聊天，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      
      // 发送取消请求
      final response = await _httpClient.getDioInstance().post(
        path,
        data: requestData,
        options: options
      );
      
      final responseData = response.data;
      final result = responseData is Map ? responseData : {};
      
      if (result['status'] == 'success') {
        print('[AiDocs] Chat generation cancelled successfully');
      } else {
        throw ds_exceptions.ServerException(
          message: result['message'] ?? 'Failed to cancel chat generation'
        );
      }
      
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      print('Unexpected error in cancelChatGeneration: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to cancel chat generation: ${e.toString()}'
      );
    }
  }

  // Dispose method if needed (e.g., to close SSE client)
  void dispose() {
    // _sseSubscription?.cancel();
    // _sseClient?.close();
    print("AiChatRemoteDataSource disposed.");
  }
} 