import 'dart:convert'; // For jsonEncode if needed

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart'; // Import Dio
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import ServerException
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:injectable/injectable.dart'; // Import injectable

import '../../domain/entities/chat_room.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_room_dto.dart';
import 'i_chat_remote_data_source.dart';

// TODO: Inject Dio instance properly via DI
// For now, creating a basic instance here for simplicity
final _dio = Dio(BaseOptions(baseUrl: "http://app.duoshaokankan.com/prod-api")); 
// NOTE: Replace with your actual base URL and configure interceptors (auth, logging)

@LazySingleton(as: IChatRemoteDataSource) // Add annotation
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {

  final Dio dio; // Inject Dio

  ChatRemoteDataSourceImpl({required this.dio}); // Constructor injection

  // Helper function to handle Dio errors and API responses
  Future<T> _handleApiCall<T>(
      Future<Response<dynamic>> Function() apiCall,
      T Function(dynamic data) dataMapper,
      {String? errorContext}) async {
    try {
      final response = await apiCall();
      // Check for successful HTTP status code (e.g., 200-299)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Check for successful business logic code (assuming 'code' field exists)
        if (response.data is Map && response.data['code'] == 200) {
          return dataMapper(response.data);
        } else {
          // Handle API-level error (e.g., validation error)
          final errorMessage = response.data is Map
              ? (response.data['msg'] ?? 'API Error')
              : 'Unknown API error structure';
          print("API Error ($errorContext): $errorMessage, Code: ${response.data?['code']}");
          throw ServerException(
              message: errorMessage, statusCode: response.statusCode);
        }
      } else {
        // Handle non-2xx HTTP status codes
        print("HTTP Error ($errorContext): Status ${response.statusCode}, Message: ${response.statusMessage}");
        throw ServerException(
            message: response.statusMessage ?? 'HTTP Error',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, etc.)
      print("DioException ($errorContext): ${e.message}, Response: ${e.response?.data}, Type: ${e.type}");
      throw ServerException(
          message: e.message ?? "Network error",
          statusCode: e.response?.statusCode);
    } catch (e) {
      // Handle other unexpected errors
      print("Unexpected error ($errorContext): $e");
      throw ServerException(message: "An unexpected error occurred ($errorContext)");
    }
  }

  @override
  Future<List<ChatRoomDto>> getChatRooms() async {
    return _handleApiCall(
      () => dio.post('/api/chat/list'), // POST request
      (data) {
        final List<dynamic> roomsJson = data['rows'] ?? [];
        return roomsJson.map((json) => ChatRoomDto.fromJson(json)).toList();
      },
      errorContext: 'getChatRooms',
    );
  }

  @override
  Future<List<ChatMessageDto>> getMessages(int chatId) async {
    return _handleApiCall(
      () => dio.post('/api/chat/message/list', data: {'chatId': chatId}), // POST with body
      (data) {
        final List<dynamic> messagesJson = data['rows'] ?? [];
        return messagesJson.map((json) => ChatMessageDto.fromJson(json)).toList();
      },
      errorContext: 'getMessages for chatId $chatId',
    );
  }

  @override
  Future<int> createRoom(int participantId) async {
    return _handleApiCall(
      () => dio.post('/api/chat/addChat', data: {'doctorId': participantId.toString()}), // POST with body
      (data) {
        if (data['data'] != null && data['data'] is int) {
          return data['data'];
        } else {
          throw ServerException(message: "Invalid data format for new room ID");
        }
      },
      errorContext: 'createRoom with participantId $participantId',
    );
  }

  @override
  Future<ChatMessageDto> sendMessage(ChatMessage message) async {
    final requestBody = {
      'chatId': message.chatId,
      'context': message.context,
      'type': message.type,
    };
    return _handleApiCall(
      () => dio.post('/common/chat/message/add', data: requestBody),
      (data) => ChatMessageDto.fromJson(data['data']), // Assuming data is in 'data' field
      errorContext: 'sendMessage',
    );
  }

  @override
  Future<void> revokeMessage(int messageId) async {
    await _handleApiCall(
      () => dio.post('/api/chat/message/withdraw', data: {'id': messageId}), // POST with body
      (data) => null, // Return type is void, successful API call is enough
      errorContext: 'revokeMessage for messageId $messageId',
    );
  }

  @override
  Future<ChatRoomDto> getRoomDetails(int chatId) async {
    return _handleApiCall(
      () => dio.get('/api/chat/get', queryParameters: {'id': chatId}), // GET with query param
      (data) => ChatRoomDto.fromJson(data['data']), // Assuming data is in 'data' field
      errorContext: 'getRoomDetails for chatId $chatId',
    );
  }

  @override
  Future<void> deleteChatMessages(List<int> messageIds, int chatId) async {
    await _handleApiCall(
      () => dio.post('/api/chat/message/delete', queryParameters: { 'ids': messageIds }),
      (data) => null, // Return type is void
      errorContext: 'deleteChatMessages',
    );
  }

} 