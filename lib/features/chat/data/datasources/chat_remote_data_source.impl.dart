import 'dart:convert'; // For jsonEncode if needed
import 'package:collection/collection.dart'; // For firstWhereOrNull

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';

import '../../domain/entities/chat_room.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_room_dto.dart';
import 'i_chat_remote_data_source.dart';
import 'package:injectable/injectable.dart'; // Add injectable import

// TODO: Inject Dio instance properly via DI
// For now, creating a basic instance here for simplicity
final _dio = Dio(BaseOptions(baseUrl: "http://app.duoshaokankan.com/prod-api")); 
// NOTE: Replace with your actual base URL and configure interceptors (auth, logging)

// @LazySingleton(as: IChatRemoteDataSource) // Add injectable annotation
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {

  final Dio dio; // Inject Dio

  ChatRemoteDataSourceImpl({required this.dio}); // Constructor injection

  // Helper to check if the API code indicates success (handles int 200 or String '200')
  bool _isSuccessCode(dynamic codeValue) {
    return (codeValue == 200) || (codeValue is String && codeValue == '200');
  }

  // Helper to handle common API response pattern
  dynamic _handleResponse(Response response, String operation) {
    final dynamic codeValue = response.data?['code'];
    if (response.statusCode == 200 && response.data != null && _isSuccessCode(codeValue)) {
      return response.data['data']; // Return the actual data part
    } else {
      final errorMessage = response.data?['msg'] ?? 'Failed to $operation';
      final errorCode = codeValue?.toString(); // Log the actual code value
      print("API Error ($operation): $errorMessage, Code: $errorCode, Status: ${response.statusCode}");
      throw ServerException(message: errorMessage, statusCode: response.statusCode);
    }
  }

  // Helper to handle common API response pattern for list results
  List<dynamic> _handleListResponse(Response response, String operation) {
     final dynamic codeValue = response.data?['code'];
     if (response.statusCode == 200 && response.data != null && _isSuccessCode(codeValue) && response.data['rows'] is List) {
        return response.data['rows'];
     } else {
        final errorMessage = response.data?['msg'] ?? 'Failed to $operation';
        final errorCode = codeValue?.toString();
        print("API Error ($operation): $errorMessage, Code: $errorCode, Status: ${response.statusCode}");
        throw ServerException(message: errorMessage, statusCode: response.statusCode);
     }
  }

    // Helper to handle simple success/failure responses (like withdraw, delete)
  void _handleVoidResponse(Response response, String operation) {
    final dynamic codeValue = response.data?['code'];
    if (response.statusCode == 200 && response.data != null && _isSuccessCode(codeValue)) {
      return; // Success
    } else {
      final errorMessage = response.data?['msg'] ?? 'Failed to $operation';
      final errorCode = codeValue?.toString();
      print("API Error ($operation): $errorMessage, Code: $errorCode, Status: ${response.statusCode}");
      throw ServerException(message: errorMessage, statusCode: response.statusCode);
    }
  }

  @override
  Future<List<ChatRoomDto>> getChatRooms() async {
    print("[API Call] Fetching chat rooms...");
    try {
      // Request response as plain text to handle potential type inconsistencies manually
      final response = await dio.post(
        '/api/chat/list',
        data: {}, 
        options: Options(responseType: ResponseType.plain), // Get raw string
      );

      // Check if response data is a non-empty string
      if (response.data is String && (response.data as String).isNotEmpty) {
        final String responseBody = response.data as String;
        print("[API Response Raw String /api/chat/list]: $responseBody");
        
        // Manually decode JSON
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);

        // Now process the decoded map using helpers (passing the map directly)
        final List<dynamic> roomsJson = _handleListResponseManual(decodedData, "load chat rooms");
        
        final rooms = roomsJson.map((json) => ChatRoomDto.fromJson(json)).toList();
        rooms.sort((a, b) {
          // 安全地解析时间字符串
          DateTime? timeA;
          DateTime? timeB;
          
          try {
            if (a.chatMessageNewVo?.createTime != null) {
              String timeString = a.chatMessageNewVo!.createTime!;
              if (timeString.contains(' ') && !timeString.contains('T')) {
                timeString = timeString.replaceFirst(' ', 'T');
              }
              timeA = DateTime.parse(timeString);
            }
          } catch (e) {
            print("[ChatRoomDto] Error parsing timeA: ${a.chatMessageNewVo?.createTime}, error: $e");
            timeA = null;
          }
          
          try {
            if (b.chatMessageNewVo?.createTime != null) {
              String timeString = b.chatMessageNewVo!.createTime!;
              if (timeString.contains(' ') && !timeString.contains('T')) {
                timeString = timeString.replaceFirst(' ', 'T');
              }
              timeB = DateTime.parse(timeString);
            }
          } catch (e) {
            print("[ChatRoomDto] Error parsing timeB: ${b.chatMessageNewVo?.createTime}, error: $e");
            timeB = null;
          }
          
          // 使用默认时间进行比较
          final DateTime finalTimeA = timeA ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime finalTimeB = timeB ?? DateTime.fromMillisecondsSinceEpoch(0);
          
          return finalTimeB.compareTo(finalTimeA); // Descending order (newest first)
        });
        return rooms;
      } else {
         print("API Error (load chat rooms): Received empty or non-string response body");
         throw ServerException(message: "Received invalid response from server", statusCode: response.statusCode);
      }

    } on DioException catch (e) {
      print("DioException fetching rooms: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error fetching rooms", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error fetching rooms: $e");
      // If error is TypeError during jsonDecode, it might indicate invalid JSON
      if (e is FormatException) { 
           throw ServerException(message: "Failed to parse server response (Invalid JSON)");
      }
      throw ServerException(message: "An unexpected error occurred while fetching chat rooms: ${e.runtimeType}");
    }
  }

  // Helper adapted for manually decoded data
  List<dynamic> _handleListResponseManual(Map<String, dynamic> decodedData, String operation) {
     final dynamic codeValue = decodedData['code'];
     if (_isSuccessCode(codeValue) && decodedData['rows'] is List) {
        return decodedData['rows'];
     } else {
        final errorMessage = decodedData['msg']?.toString() ?? 'Failed to $operation';
        final errorCode = codeValue?.toString();
        print("API Business Error ($operation): $errorMessage, Code: $errorCode");
        // Use a generic status code like 400 for business logic errors if original status was 200
        throw ServerException(message: errorMessage, statusCode: 400); 
     }
  }

  @override
  Future<List<ChatMessageDto>> getMessages(int chatId, {int pageNum = 1, int pageSize = 20}) async {
    print("[API Call] Fetching messages for chatId: $chatId, pageNum: $pageNum, pageSize: $pageSize...");
    try {
      final response = await dio.post('/api/chat/message/list', data: {
        'chatId': chatId,
        'pageNum': pageNum,
        'pageSize': pageSize
      });
      final List<dynamic> messagesJson = _handleListResponse(response, "load messages");
      
      // 转换为DTO对象
      final List<ChatMessageDto> messageDtos = messagesJson.map((json) => ChatMessageDto.fromJson(json)).toList();
      
      // 打印日志以便了解排序情况
      if (messageDtos.isNotEmpty) {
        final firstMsg = messageDtos.first;
        final lastMsg = messageDtos.last;
        print("[API Response] First message time: ${firstMsg.createTime}, last message time: ${lastMsg.createTime}");
      }
      
      // 确保按时间升序（从旧到新）排序
      messageDtos.sort((a, b) {
        // 安全地解析时间字符串
        DateTime? timeA;
        DateTime? timeB;
        
        try {
          if (a.createTime != null) {
            String timeString = a.createTime!;
            if (timeString.contains(' ') && !timeString.contains('T')) {
              timeString = timeString.replaceFirst(' ', 'T');
            }
            timeA = DateTime.parse(timeString);
          }
        } catch (e) {
          print("[ChatMessageDto] Error parsing timeA: ${a.createTime}, error: $e");
          timeA = null;
        }
        
        try {
          if (b.createTime != null) {
            String timeString = b.createTime!;
            if (timeString.contains(' ') && !timeString.contains('T')) {
              timeString = timeString.replaceFirst(' ', 'T');
            }
            timeB = DateTime.parse(timeString);
          }
        } catch (e) {
          print("[ChatMessageDto] Error parsing timeB: ${b.createTime}, error: $e");
          timeB = null;
        }
        
        // 使用默认时间进行比较
        final DateTime finalTimeA = timeA ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime finalTimeB = timeB ?? DateTime.fromMillisecondsSinceEpoch(0);
        
        return finalTimeA.compareTo(finalTimeB); // 升序排列 (旧->新)
      });
      
      return messageDtos;
    } on DioException catch (e) {
      print("DioException fetching messages: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error fetching messages", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error fetching messages: $e");
      throw ServerException(message: "An unexpected error occurred while fetching messages");
    }
  }

  @override
  Future<int> createRoom(
    int participantId, {
    int? productId, // 新增可选的商品ID参数
  }) async {
    print("[API Call] Creating room with participantId: $participantId, productId: $productId");
    try {
      // 准备请求数据 - 根据participantId判断用户类型
      final Map<String, dynamic> requestData = {
        'doctorId': participantId.toString(), // Send participantId as string
      };
      
      // 根据participantId判断用户类型
      if (participantId == 1) {
        // 系统管理员使用ADMIN类型
        requestData['type'] = 'ADMIN';
        print("[API Call] Using type: ADMIN for system administrator chat creation.");
      } else {
        // 其他用户使用MEMBER类型
        requestData['type'] = 'MEMBER';
        print("[API Call] Using type: MEMBER for regular user chat creation.");
      }
      
      // 如果提供了productId，添加到请求数据中
      if (productId != null) {
        requestData['productId'] = productId;
      }
      
      print("[API Call] Request data: $requestData");

      final response = await dio.post(
        '/api/chat/addChat',
        data: requestData, // Send the complete data map
        // Assuming default responseType: json is okay here
      );
      // Handle response, expecting a chat room object with 'id' field in the 'data' field
      final dynamic data = _handleResponse(response, "create room"); 
      if (data is Map<String, dynamic> && data['id'] is int) {
        // API返回完整的聊天室对象，提取id字段
        print("[API Success] Created chat room with ID: ${data['id']}");
        return data['id'] as int;
      } else if (data is int) {
        // 兼容直接返回ID的情况
        print("[API Success] Created chat room with ID: $data");
        return data;
      } else {
         print("API Error (create room): Expected chat room object with 'id' field in 'data', but got ${data?.runtimeType}");
         print("API Error (create room): Data content: $data");
         throw ServerException(message: "Invalid response format for create room");
      }
    } on DioException catch (e) {
      print("DioException creating room: ${e.message}, Response: ${e.response?.data}");
      
      // 提供更具体的错误信息
      String errorMessage = "网络连接失败";
      if (e.response?.data is Map) {
        final responseData = e.response!.data as Map;
        final serverMessage = responseData['msg']?.toString();
        
        if (serverMessage != null) {
          if (serverMessage.contains("用户不存在")) {
            errorMessage = participantId == 1 
                ? "系统管理员账户配置异常，请联系技术支持" 
                : "目标用户不存在";
          } else if (serverMessage.contains("聊天对象类型要传递")) {
            errorMessage = "请求参数错误，请重试";
          } else if (serverMessage.contains("空指针异常") && participantId == 1) {
            errorMessage = "系统管理员账户未配置，请联系技术支持进行初始化";
          } else {
            errorMessage = serverMessage;
          }
        }
      }
      
      throw ServerException(
        message: errorMessage, 
        statusCode: e.response?.statusCode
      );
    } catch (e) {
      print("Unexpected error creating room: $e");
      throw ServerException(message: "创建聊天室时发生未知错误");
    }
  }

  @override
  Future<ChatMessageDto> sendMessage(ChatMessage message) async {
    print("[API Call] Sending message: ${message.context}");
    final requestBody = {
      'chatId': message.chatId,
      'context': message.context,
      'type': message.type,
    };
    try {
      final response = await dio.post('/common/chat/message/add', data: requestBody);
      final dynamic data = _handleResponse(response, "send message");
      return ChatMessageDto.fromJson(data);
    } on DioException catch (e) {
      print("DioException sending message: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error sending message", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error sending message: $e");
      throw ServerException(message: "An unexpected error occurred");
    }
  }

  @override
  Future<void> revokeMessage(int messageId) async {
    print("[API Call] Revoking messageId: $messageId...");
    try {
      final response = await dio.post('/api/chat/message/withdraw', data: {'id': messageId});
      _handleVoidResponse(response, "revoke message");
    } on DioException catch (e) {
       print("DioException revoking message: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error revoking message", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error revoking message: $e");
      throw ServerException(message: "An unexpected error occurred while revoking message");
    }
  }

  @override
  Future<ChatRoomDto> getRoomDetails(int chatId) async {
    print("[API Call] Fetching room details for chatId: $chatId...");
    try {
      final response = await dio.get('/api/chat/get', queryParameters: {'id': chatId});
      final dynamic data = _handleResponse(response, "fetch room details");
      return ChatRoomDto.fromJson(data);
    } on DioException catch (e) {
      print("DioException fetching room details: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error fetching room details", statusCode: e.response?.statusCode);
    } catch (e) {
       print("Unexpected error fetching room details: $e");
      throw ServerException(message: "An unexpected error occurred while fetching room details");
    }
  }

  @override
  Future<void> deleteChatMessages(List<int> messageIds, int chatId) async {
    print("[API Call] Deleting messages: $messageIds for chatId: $chatId...");
    try {
       // Assuming POST request with list of IDs in the body based on TODO doc
      // NOTE: If backend expects query parameter list of strings, adjust accordingly
      final response = await dio.post('/api/chat/message/delete', data: { 'ids': messageIds });
      _handleVoidResponse(response, "delete messages");
    } on DioException catch (e) {
       print("DioException deleting messages: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error deleting messages", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error deleting messages: $e");
      throw ServerException(message: "An unexpected error occurred while deleting messages");
    }
  }
} 