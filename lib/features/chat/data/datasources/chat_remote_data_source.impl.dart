import 'dart:convert'; // For jsonEncode if needed

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';

import '../../domain/entities/chat_room.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_room_dto.dart';
import 'i_chat_remote_data_source.dart';

// TODO: Inject Dio instance properly via DI
// For now, creating a basic instance here for simplicity
final _dio = Dio(BaseOptions(baseUrl: "http://app.duoshaokankan.com/prod-api")); 
// NOTE: Replace with your actual base URL and configure interceptors (auth, logging)

class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {

  final Dio dio; // Inject Dio

  ChatRemoteDataSourceImpl({required this.dio}); // Constructor injection

  @override
  Future<List<ChatRoomDto>> getChatRooms() async {
    // TODO: Implement API call for /api/chat/list
    print("[API Call] Fetching chat rooms...");
    // Simulate API call for now
    await Future.delayed(const Duration(milliseconds: 500));
    // Replace with actual Dio call later
    // Example structure:
    /*
    try {
      final response = await dio.post('/api/chat/list');
      if (response.statusCode == 200 && response.data['rows'] != null) {
        final List<dynamic> roomsJson = response.data['rows'];
        return roomsJson.map((json) => ChatRoomDto.fromJson(json)).toList();
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to load chat rooms', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error fetching rooms", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("getChatRooms not implemented yet in RemoteDataSource");
  }

  @override
  Future<List<ChatMessageDto>> getMessages(int chatId) async {
    // TODO: Implement API call for /api/chat/message/list
    print("[API Call] Fetching messages for chatId: $chatId...");
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    // Replace with actual Dio call
    /*
    try {
      final response = await dio.post('/api/chat/message/list', data: {'chatId': chatId});
      if (response.statusCode == 200 && response.data['rows'] != null) {
        final List<dynamic> messagesJson = response.data['rows'];
        return messagesJson.map((json) => ChatMessageDto.fromJson(json)).toList();
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to load messages', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error fetching messages", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("getMessages not implemented yet in RemoteDataSource");
  }

  @override
  Future<int> createRoom(int participantId) async {
    // TODO: Implement API call for /api/chat/addChat
    print("[API Call] Creating room with participantId: $participantId...");
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));
    // Replace with actual Dio call
    /*
    try {
      final response = await dio.post('/api/chat/addChat', data: {'doctorId': participantId.toString()}); // Assuming participantId maps to doctorId
      if (response.statusCode == 200 && response.data['data'] != null && response.data['data'] is int) {
        return response.data['data'];
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to create room', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error creating room", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("createRoom not implemented yet in RemoteDataSource");
  }

  @override
  Future<ChatMessageDto> sendMessage(ChatMessage message) async {
    print("[API Call] Sending message: ${message.context}");
    final requestBody = {
      'chatId': message.chatId,
      'context': message.context,
      'type': message.type,
      // Backend likely determines memberId/doctorId based on token
    };
    try {
      final response = await dio.post('/common/chat/message/add', data: requestBody);

      if (response.statusCode == 200 && response.data['code'] == 200 && response.data['data'] != null) {
        // Ensure the response data is correctly parsed
        return ChatMessageDto.fromJson(response.data['data']);
      } else {
        // Handle API error response
        final errorMessage = response.data?['msg'] ?? 'Failed to send message';
        print("API Error sending message: $errorMessage, Code: ${response.data?['code']}, Status: ${response.statusCode}");
        throw ServerException(message: errorMessage, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle network or Dio specific errors
      print("DioException sending message: ${e.message}, Response: ${e.response?.data}");
      throw ServerException(message: e.message ?? "Network error sending message", statusCode: e.response?.statusCode);
    } catch (e) {
      // Handle unexpected errors
      print("Unexpected error sending message: $e");
      throw ServerException(message: "An unexpected error occurred");
    }
  }

  @override
  Future<void> revokeMessage(int messageId) async {
    // TODO: Implement API call for /api/chat/message/withdraw
    print("[API Call] Revoking messageId: $messageId...");
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 200));
    // Replace with actual Dio call
    /*
    try {
      final response = await dio.post('/api/chat/message/withdraw', data: {'id': messageId});
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return; // Success
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to revoke message', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error revoking message", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("revokeMessage not implemented yet in RemoteDataSource");
  }

  @override
  Future<ChatRoomDto> getRoomDetails(int chatId) async {
    // TODO: Implement API call for /api/chat/get
    print("[API Call] Fetching room details for chatId: $chatId...");
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Replace with actual Dio call
    /*
    try {
      final response = await dio.get('/api/chat/get', queryParameters: {'id': chatId});
      if (response.statusCode == 200 && response.data['data'] != null) {
        return ChatRoomDto.fromJson(response.data['data']);
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to load room details', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error fetching room details", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("getRoomDetails not implemented yet in RemoteDataSource");
  }

  @override
  Future<void> deleteChatMessages(List<int> messageIds, int chatId) async {
    // TODO: Implement API call for /api/chat/message/delete
    print("[API Call] Deleting messages: $messageIds for chatId: $chatId...");
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Replace with actual Dio call - NOTE: API Spec shows query param, but implementation might use body
    /*
    try {
      final response = await dio.post('/api/chat/message/delete', queryParameters: { 'ids': messageIds }); // Or use data: { 'ids': messageIds } if needed
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return; // Success
      } else {
        throw ServerException(message: response.data['msg'] ?? 'Failed to delete messages', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Network error deleting messages", statusCode: e.response?.statusCode);
    }
    */
    throw UnimplementedError("deleteChatMessages not implemented yet in RemoteDataSource");
  }

} 