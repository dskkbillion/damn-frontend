import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:convert';
import 'dart:async';
// Needed for File type if using local file upload later

import 'package:http/http.dart' as http; // Assuming we might need this for SSE later, keep for context
// Import dotenv
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 添加FlutterSecureStorage导入

import '../../../../core/network/i_http_client.dart';
// import '../../../../core/error/exceptions.dart'; // Using DataSource specific exceptions
import '../models/ai_conversation_model.dart';
import '../models/ai_chat_message_model.dart';
import '../models/related_service_model.dart';
// import '../models/chat_allocation_result_model.dart'; // Not directly used in return types
import 'i_ai_chat_remote_data_source.dart';
import 'exceptions.dart' as ds_exceptions;
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

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

  // Helper to get base URL from region config
  String _getModelBaseUrl() {
     return RegionConfig.modelBaseUrl;
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
  Future<Map<String, dynamic>> fetchConversations({
    required int userId,
    int page = 1,
    int pageSize = 20,
    String orderBy = 'desc',
  }) async {
    const String path = '/model/chat/list';
    AppLogger.d("Fetching conversations using path: $path with pagination");
    
    final Map<String, dynamic> requestData = {
      'user_id': userId,
      'page': page,
      'page_size': pageSize,
      'order_by': orderBy,
    };
    
    try {
      // 获取token - 添加手动获取token的代码
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 获取对话列表，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token，不添加Bearer前缀
        }
      );
      AppLogger.d("[AiDocs] 请求参数: $requestData");
      
      // 直接使用Dio实例，带上认证头
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      // 解析对话列表
      List<AiConversationModel> conversations = [];
      
      if (data != null && data['conversations'] is List) {
        conversations = (data['conversations'] as List)
            .map((convJson) => AiConversationModel.fromJson(convJson))
            .toList();
        
        // 构造包含分页信息的返回结果
        return {
          'conversations': conversations,
          'currentPage': data['current_page'] ?? page,
          'totalPages': data['total_pages'] ?? 0,
          'totalConversations': data['total_conversations'] ?? conversations.length,
          'hasMore': data['has_more'] ?? (conversations.length >= pageSize),
        };
      } else if (data != null && data is List) {
        // 处理直接返回对话列表的格式（向后兼容）
        conversations = (data)
            .map((convJson) => AiConversationModel.fromJson(convJson))
            .toList();
        
        // 构造默认分页结果
        return {
          'conversations': conversations,
          'currentPage': page,
          'totalPages': 0,
          'totalConversations': conversations.length,
          'hasMore': conversations.length >= pageSize,
        };
      } else {
        AppLogger.d('Warning: fetchConversations received unexpected format. Data: $data');
        conversations = [];
      }
      
      // 如果响应不包含分页信息，构造默认的分页结果
      return {
        'conversations': conversations,
        'currentPage': page,
        'totalPages': 0,
        'totalConversations': conversations.length,
        'hasMore': conversations.length >= pageSize,
      };
      
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in fetchConversations at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to fetch conversations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> loadHistory({
    required int conversationId,
    required int userId,
    int page = 1,
    int pageSize = 50,
    String orderBy = 'desc',
    bool getAll = false,
  }) async {
    const String path = '/model/chat/messages';
    AppLogger.d("Loading history using path: $path for conv $conversationId with pagination");
    
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'page': page,
      'page_size': pageSize,
      'order_by': orderBy,
      'get_all': getAll,
    };

    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 加载历史记录，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求参数: $requestData");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      // 解析消息列表
      List<AiChatMessageModel> messages = [];
      
      if (data != null && data is List) { 
        AppLogger.d("[DATASOURCE DEBUG] Parsing ${data.length} messages from root data list.");
        messages = (data).map((msgJson) {
          AppLogger.d("[DATASOURCE DEBUG] Parsing msgJson: ${jsonEncode(msgJson)}");
           if (msgJson is Map<String, dynamic>) { 
             AppLogger.d("[DATASOURCE DEBUG]  -> id type: ${msgJson['id']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> message_id type: ${msgJson['message_id']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> conversation_id type: ${msgJson['conversation_id']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> role type: ${msgJson['role']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> content type: ${msgJson['content']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> files type: ${msgJson['files']?.runtimeType}");
             AppLogger.d("[DATASOURCE DEBUG]  -> timestamp type: ${msgJson['timestamp']?.runtimeType}");
           }
           try {
              return AiChatMessageModel.fromJson(msgJson as Map<String, dynamic>);
           } catch (e, stacktrace) {
              AppLogger.d("[DATASOURCE ERROR] Failed to parse msgJson: $e");
              AppLogger.d("[DATASOURCE ERROR] Stacktrace: $stacktrace");
              AppLogger.d("[DATASOURCE ERROR] Failing msgJson: ${jsonEncode(msgJson)}");
              rethrow;
           }
        }).toList();
      } else if (data != null && data is Map<String, dynamic>) {
        // 处理可能包含分页信息的响应格式
        if (data['messages'] is List) {
          AppLogger.d("[DATASOURCE DEBUG] Parsing ${(data['messages'] as List).length} messages from nested 'messages' key.");
          messages = (data['messages'] as List).map((msgJson) {
             AppLogger.d("[DATASOURCE DEBUG] Parsing msgJson: ${jsonEncode(msgJson)}"); 
            if (msgJson is Map<String, dynamic>) { 
               AppLogger.d("[DATASOURCE DEBUG]  -> id type: ${msgJson['id']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> message_id type: ${msgJson['message_id']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> conversation_id type: ${msgJson['conversation_id']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> role type: ${msgJson['role']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> content type: ${msgJson['content']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> files type: ${msgJson['files']?.runtimeType}");
               AppLogger.d("[DATASOURCE DEBUG]  -> timestamp type: ${msgJson['timestamp']?.runtimeType}");
            }
            try {
              return AiChatMessageModel.fromJson(msgJson as Map<String, dynamic>); 
            } catch (e, stacktrace) {
              AppLogger.d("[DATASOURCE ERROR] Failed to parse msgJson: $e");
              AppLogger.d("[DATASOURCE ERROR] Stacktrace: $stacktrace");
              AppLogger.d("[DATASOURCE ERROR] Failing msgJson: ${jsonEncode(msgJson)}");
              rethrow; 
            }
          }).toList();
        }
        
        // 构造包含分页信息的返回结果
        return {
          'messages': messages,
          'currentPage': data['current_page'] ?? page,
          'totalPages': data['total_pages'] ?? 0,
          'totalMessages': data['total_messages'] ?? messages.length,
          'hasMore': data['has_more'] ?? (messages.length >= pageSize),
        };
      } else {
        AppLogger.d('Warning: loadHistory received unexpected format for $conversationId. Data: $data');
        messages = [];
      }
      
      // 如果响应不包含分页信息，构造默认的分页结果
      return {
        'messages': messages,
        'currentPage': page,
        'totalPages': 0,
        'totalMessages': messages.length,
        'hasMore': messages.length >= pageSize,
      };
      
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in loadHistory for $conversationId at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to load history for $conversationId: ${e.toString()}');
    }
  }

  @override
  Future<int> createConversation({
    required int userId,
    String? title,
  }) async {
    const String path = '/model/chat/create';
    AppLogger.d("Creating conversation using path: $path");
    final Map<String, dynamic> requestData = {'user_id': userId};
    if (title != null) requestData['title'] = title;
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 创建会话，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      
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
      AppLogger.d('Unexpected error in createConversation at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/delete';
    AppLogger.d("Deleting conversation $conversationId using path: $path");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 删除会话，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      
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
      AppLogger.d('Unexpected error in deleteConversation for $conversationId at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to delete conversation $conversationId: ${e.toString()}');
    }
  }

  @override
  Stream<String> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
    List<String>? audioUrls,
    String? transcription,
  }) {
    const String path = '/model/chat';
    AppLogger.d("Streaming chat completion using path: $path");
    
    // 构建请求数据，支持新的语音消息参数
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'message': message,
      'stream': true, // 确保启用流式响应
    };
    
    // 添加音频URL和转录文本参数
    if (audioUrls != null && audioUrls.isNotEmpty) {
      requestData['audio_urls'] = audioUrls;
      AppLogger.d('[DataSource] Adding audio_urls: $audioUrls');
    }
    
    if (transcription != null && transcription.isNotEmpty) {
      requestData['transcription'] = transcription;
      AppLogger.d('[DataSource] Adding transcription: $transcription');
    }
    
    // #369 多模态附件分流: 非图片扩展名走 files, 其它默认走 image_urls
    // 原版本用 substring 匹配("image"/"img" 会误匹配 OSS path 里的任意 URL),已弃用
    // omni 负责未知格式拒收 → 走 onError 抛 ServerFailure, 不在前端兜底 (CLAUDE.md "No silent fallbacks")
    if (fileUrls.isNotEmpty) {
      const nonImageExts = {
        '.pdf', '.mp4', '.mov', '.avi', '.mkv', '.webm',
        '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
        '.zip', '.rar', '.7z', '.tar', '.gz',
        '.mp3', '.wav', '.m4a', '.flac', '.ogg',  // 音频默认应该用 audio_urls 字段,这里仅兜底
      };
      final hasNonImage = fileUrls.any((url) {
        final lower = url.toLowerCase();
        // 去掉 query string 后看扩展名
        final pathOnly = lower.split('?').first;
        return nonImageExts.any((ext) => pathOnly.endsWith(ext));
      });
      if (hasNonImage) {
        requestData['files'] = fileUrls;
        AppLogger.d('[DataSource] Non-image files detected, adding files: $fileUrls');
      } else {
        requestData['image_urls'] = fileUrls;
        AppLogger.d('[DataSource] Adding image_urls (omni multimodal): $fileUrls');
      }
    }
    
    AppLogger.d('[DataSource] Calling streamChatCompletion with data: $requestData');

    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = storage.read(key: 'auth_token').then((token) {
        AppLogger.d("[AiDocs] 流式聊天，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
        
        // 创建完整的URL
        final String baseUrl = _getModelBaseUrl();
        String fullUrl = baseUrl.endsWith('/') ? baseUrl + path.substring(1) : baseUrl + path;
        if (!fullUrl.startsWith('http')) {
          fullUrl = 'http://$fullUrl';
        }
        AppLogger.d("[AiDocs] 完整URL: $fullUrl");
        
        // 创建HTTP请求
        final request = http.Request('POST', Uri.parse(fullUrl));
        request.headers['Content-Type'] = 'application/json';
        
        // 添加认证头
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = token; // 直接使用token
        }
        AppLogger.d("[AiDocs] SSE请求头: ${request.headers}");
        
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
                  AppLogger.d('[DataSource - SSE Stream] Error: $error');
                  sink.addError(ds_exceptions.NetworkException(
                    message: "Network error during stream: ${error.toString()}"
                  ));
                },
                handleDone: (sink) {
                  AppLogger.d('[DataSource - SSE Stream] Stream completed.');
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
      AppLogger.d("Error initiating streamChatCompletion to $path: $e");
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
                AppLogger.d('[DataSource - SSE] Content chunk: $contentChunk');
                sink.add(contentChunk);
              }
            }
          }
          break;
          
        case 'conversation.message.completed':
          AppLogger.d('[DataSource - SSE] Message completed');
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            AppLogger.d('[DataSource - SSE] Completion data: $jsonData');
          }
          // 发送特殊标记表示消息完成
          sink.add('[COMPLETED]');
          break;
          
        case 'conversation.message.cancelled':
          AppLogger.d('[DataSource - SSE] Message cancelled by user');
          sink.add('[CANCELLED]');
          break;
          
        case 'conversation.message.error':
          AppLogger.d('[DataSource - SSE] Message error');
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            final errorMsg = jsonData['error'] ?? 'Unknown error';
            sink.addError(ds_exceptions.ServerException(message: errorMsg));
          }
          break;
          
        case 'done':
          AppLogger.d('[DataSource - SSE] Stream done');
          sink.add('[DONE]');
          break;
          
        case 'conversation.message.meta':
          // 处理元数据事件，检测是否跳过用户消息显示
          if (data.isNotEmpty) {
            final jsonData = jsonDecode(data);
            AppLogger.d('[DataSource - SSE] Meta data: $jsonData');
            if (jsonData is Map<String, dynamic>) {
              final skipUserMessage = jsonData['skip_user_message_display'] as bool?;
              if (skipUserMessage == true) {
                AppLogger.d('[DataSource - SSE] Received skip_user_message_display = true');
                // 发送特殊标记给BLoC，表示需要跳过用户消息显示
                sink.add('[SKIP_USER_MESSAGE]');
              }
            }
          }
          break;

        case 'conversation.user_audio_transcript':
          // #371 omni 回写用户音频转写文本 — bloc 收到后 patch [语音消息] 占位
          // 隔离 try/catch — malformed transcript JSON 不应中断整个 stream (Architect P2)
          if (data.isNotEmpty) {
            try {
              final jsonData = jsonDecode(data);
              AppLogger.d('[DataSource - SSE] #371 user_audio_transcript: $jsonData');
              if (jsonData is Map<String, dynamic>) {
                final transcript = jsonData['transcript'] as String?;
                if (transcript != null && transcript.isNotEmpty) {
                  // 用特殊标记把 transcript 文本透传给 BLoC, 格式 [USER_AUDIO_TRANSCRIPT]<文本>
                  sink.add('[USER_AUDIO_TRANSCRIPT]$transcript');
                }
              }
            } catch (e) {
              // transcript 解析失败不影响主回复流, 仅日志
              AppLogger.d('[DataSource - SSE] #371 transcript JSON parse 失败 (忽略): $e');
            }
          }
          break;


        default:
          AppLogger.d('[DataSource - SSE] Unknown event type: $event');
          break;
      }
    } catch (e) {
      AppLogger.d('[DataSource - SSE] Error processing event $event: $e. Data: $data');
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
    AppLogger.d("Fetching related services using path: $path");
    
    Map<String, dynamic> requestData = {
      'user_id': userId,
    };
    
    if (conversationId > 0) {
      requestData['conversation_id'] = conversationId;

      // message_id是可选参数，只有明确提供时才添加
      // 根据API文档，新会话推荐时可以不传message_id
      if (messageId != null && messageId > 0) {
        requestData['message_id'] = messageId;
      }
    }
    
    if (limit != null) {
      requestData['limit'] = limit;
    } else {
      requestData['limit'] = 10;
    }
    
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 获取相关服务，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
      
      // 检查是否是429频率限制错误
      if (response.statusCode == 429) {
        final data = _handleResponse(responseData);
        throw ds_exceptions.RateLimitException(
          message: data['message'] ?? '请求过于频繁',
          rateLimitData: data['data'],
        );
      }
      
      final data = _handleResponse(responseData);
      
      AppLogger.d('[DataSource] Related services response: ${jsonEncode(data)}');
      
      if (data != null && data['items'] is List) {
        return (data['items'] as List).map<RelatedServiceModel>((serviceJson) {
           AppLogger.d('[DataSource] Item JSON: ${jsonEncode(serviceJson)}');
           try {
             return RelatedServiceModel(
               id: serviceJson['id'] as int? ?? 0,
               title: serviceJson['name'] as String? ?? 'Unknown service',
               imageUrl: serviceJson['mainImage'] as String? ?? '',
               price: (serviceJson['price'] as num?)?.toDouble() ?? 0.0,
               tenantId: serviceJson['tenantId'] as int? ?? 0,
             );
           } catch (e, stacktrace) {
              AppLogger.d('[DataSource] Error parsing item JSON: $e');
              AppLogger.d(stacktrace); 
              rethrow;
           }
         }).toList();
      } else if (data != null && data['services'] is List) {
        return (data['services'] as List).map((serviceJson) {
           AppLogger.d('[DataSource] Service JSON: ${jsonEncode(serviceJson)}');
           try {
             return RelatedServiceModel.fromJson(serviceJson);
           } catch (e, stacktrace) {
              AppLogger.d('[DataSource] Error parsing service JSON: $e');
              AppLogger.d(stacktrace); 
              rethrow;
           }
         }).toList();
      } else {
        AppLogger.d('Warning: getRelatedServices received unexpected format. Data: $data');
        return [];
      }
    } on ds_exceptions.RateLimitException {
      rethrow;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in getRelatedServices at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to get related services: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getRateLimitStatus({
    required int userId,
  }) async {
    final String path = '/recsys/rate-limit/status/$userId';
    AppLogger.d("Fetching rate limit status using path: $path");
    
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 获取频率限制状态，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token,
        }
      );
      
      final response = await _httpClient.getDioInstance().get(
        path,
        options: options
      );
      
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      return data as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in getRateLimitStatus: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to get rate limit status: ${e.toString()}'
      );
    }
  }

  @override
  Future<Map<String, dynamic>> resetUserRateLimit({
    required int userId,
    String? serviceType,
    String? ruleName,
  }) async {
    final String path = '/recsys/rate-limit/reset/$userId';
    AppLogger.d("Resetting user rate limit using path: $path");
    
    final Map<String, String> queryParams = {};
    if (serviceType != null) {
      queryParams['service_type'] = serviceType;
    }
    if (ruleName != null) {
      queryParams['rule_name'] = ruleName;
    }
    
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 重置频率限制，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token,
        }
      );
      
      final response = await _httpClient.getDioInstance().post(
        path,
        queryParameters: queryParams,
        options: options
      );
      
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      return data as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in resetUserRateLimit: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to reset user rate limit: ${e.toString()}'
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getRateLimitConfig() async {
    const String path = '/recsys/rate-limit/config';
    AppLogger.d("Fetching rate limit config using path: $path");
    
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 获取频率限制配置，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token,
        }
      );
      
      final response = await _httpClient.getDioInstance().get(
        path,
        options: options
      );
      
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      return data as Map<String, dynamic>;
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in getRateLimitConfig: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to get rate limit config: ${e.toString()}'
      );
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
    AppLogger.d("Allocating resource using path: $path");
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'item': item,
      'merchant_id': merchantId,
    };
    
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 分发资源，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头和更长超时设置的请求选项
      final options = Options(
        // 设置更长的超时时间（60秒接收超时）
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      AppLogger.d("使用60秒超时发起allocate请求");
      
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
      AppLogger.d('Unexpected error in allocateChatResource at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to allocate resource: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDispatchHistory({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/allocations/list';
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
      );
      final response = await _httpClient.getDioInstance().get(
        path,
        queryParameters: {
          'conversation_id': conversationId,
          'user_id': userId,
        },
        options: options,
      );
      final data = _handleResponse(response.data);
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in getDispatchHistory at $path: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to fetch dispatch history: ${e.toString()}',
      );
    }
  }

  // #368 deleted transcribeAudio() implementation — omni 直接理解音频 (#360)
  // 后端 /model/chat/audio endpoint 保留到 2026-06-04 (老 app 版本兼容期),
  // 此前端方法删除后, 老 app 自身 fallback 路径仍能调它(不通过此 client)。

  @override
  Future<void> cancelChatGeneration({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/cancel';
    AppLogger.d("Cancelling chat generation for conversation $conversationId");
    
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 取消聊天，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
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
        AppLogger.d('[AiDocs] Chat generation cancelled successfully');
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
      AppLogger.d('Unexpected error in cancelChatGeneration: $e');
      throw ds_exceptions.DataSourceException(
        message: 'Failed to cancel chat generation: ${e.toString()}'
      );
    }
  }

  @override
  Future<String> updateConversationTitle({
    required int conversationId,
    required int userId,
    required String title,
  }) async {
    const String path = '/model/chat/title/update';
    AppLogger.d("Updating conversation title using path: $path");
    
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
      'title': title,
    };
    
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 更新标题，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      if (data != null && data['title'] is String) {
        return data['title'];
      } else {
        throw ds_exceptions.DataSourceException(message: 'Invalid title format in API response');
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in updateConversationTitle at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to update conversation title: ${e.toString()}');
    }
  }

  @override
  Future<String> generateConversationTitle({
    required int conversationId,
    required int userId,
  }) async {
    const String path = '/model/chat/title/generate';
    AppLogger.d("Generating conversation title using path: $path");
    
    final Map<String, dynamic> requestData = {
      'conversation_id': conversationId,
      'user_id': userId,
    };
    
    try {
      // 获取token
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      AppLogger.d("[AiDocs] 生成标题，token: ${token != null ? '${token.substring(0, 15)}...' : 'null'}");
      
      // 创建包含认证头的选项
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': token, // 直接使用token
        }
      );
      AppLogger.d("[AiDocs] 请求头: ${options.headers}");
      
      // 直接使用Dio实例
      final response = await _httpClient.getDioInstance().post(
        path, 
        data: requestData,
        options: options
      );
      
      // 处理响应
      final responseData = response.data;
      final data = _handleResponse(responseData);
      
      if (data != null && data['title'] is String) {
        return data['title'];
      } else {
        throw ds_exceptions.DataSourceException(message: 'Invalid title format in API response');
      }
    } on ds_exceptions.ServerException {
      rethrow;
    } on ds_exceptions.NetworkException {
      rethrow;
    } catch (e) {
      AppLogger.d('Unexpected error in generateConversationTitle at $path: $e');
      throw ds_exceptions.DataSourceException(message: 'Failed to generate conversation title: ${e.toString()}');
    }
  }

  // Dispose method if needed (e.g., to close SSE client)
  void dispose() {
    // _sseSubscription?.cancel();
    // _sseClient?.close();
    AppLogger.d("AiChatRemoteDataSource disposed.");
  }
} 