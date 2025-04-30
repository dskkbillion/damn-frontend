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
          final DateTime timeA = (a.chatMessageNewVo?.createTime as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime timeB = (b.chatMessageNewVo?.createTime as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return timeB.compareTo(timeA); // Descending order
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
  Future<List<ChatMessageDto>> getMessages(int chatId) async {
    print("[API Call] Fetching messages for chatId: $chatId...");
    try {
      final response = await dio.post('/api/chat/message/list', data: {'chatId': chatId});
      final List<dynamic> messagesJson = _handleListResponse(response, "load messages");
       // API likely returns newest first, reverse here to get chronological order (oldest first)
       // Let the Bloc handle the final ordering if needed based on UI requirements.
       // For now, return as received.
      return messagesJson.map((json) => ChatMessageDto.fromJson(json)).toList();
    } on DioException catch (e) {
      print("DioException fetching messages: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error fetching messages", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error fetching messages: $e");
      throw ServerException(message: "An unexpected error occurred while fetching messages");
    }
  }

  @override
  Future<int> createRoom(int participantId) async {
    print("[API Call] Creating room with participantId: $participantId");
    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'doctorId': participantId.toString() // Send participantId as string
      };
      
      // FIX: Add type field based on participantId
      if (participantId == 1) {
         requestData['type'] = 'ADMIN';
         print("[API Call] Added type: ADMIN for admin chat creation.");
      } else {
         // Assuming any other ID represents a standard member/doctor chat
         requestData['type'] = 'MEMBER'; 
         print("[API Call] Added type: MEMBER for chat creation.");
      }

      final response = await dio.post(
        '/api/chat/addChat',
        data: requestData, // Send the complete data map
        // Assuming default responseType: json is okay here
      );
      // Handle response, expecting an integer chat ID in the 'data' field
      final dynamic data = _handleResponse(response, "create room"); 
      if (data is int) {
        return data;
      } else {
         print("API Error (create room): Expected integer chat ID in 'data', but got ${data?.runtimeType}");
         throw ServerException(message: "Invalid response format for create room");
      }
    } on DioException catch (e) {
      print("DioException creating room: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error creating room", statusCode: e.response?.statusCode);
    } catch (e) {
      print("Unexpected error creating room: $e");
      throw ServerException(message: "An unexpected error occurred while creating room: ${e.runtimeType}");
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