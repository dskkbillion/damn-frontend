import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/i_http_client.dart'; // Assume this interface exists
import '../../../../core/network/network_info.dart'; // Assume this exists
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import './i_chat_remote_data_source.dart';

/// 远程数据源实现
class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final IHttpClient client; // Use the injected HTTP client
  final NetworkInfo networkInfo; // To check connectivity
  
  // TODO (Critical): Get base URL from configuration (e.g., environment variables via AppConfig class) instead of hardcoding.
  final String _apiBaseUrl = "http://17-8187.proxy.product-demo.cn:8000"; // Placeholder

  ChatRemoteDataSourceImpl({required this.client, required this.networkInfo});

  // Helper to get standard headers (including Auth)
  Future<Map<String, String>> _getHeaders() async {
     // TODO (Critical): Get token from Auth module instead of placeholder.
     // Requires injecting an IAuthRepository/IAuthService and calling a method like authRepository.getCurrentToken().
     // Ensure the Auth module handles secure storage (e.g., flutter_secure_storage).
     String? token = "YOUR_AUTH_TOKEN_PLACEHOLDER"; // Replace with actual token retrieval
     return {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': token,
         'clienttype': '1', // Example default
         'client': Platform.isIOS ? 'ios' : 'android', // Example platform detection
         'version': '100', // Example default
     };
  }

  // Helper function to handle API calls and error mapping
  Future<Either<Failure, T>> _handleApiCall<T>(
     Future<http.Response> Function() apiCall,
     T Function(dynamic json) dataMapper,
  ) async {
     if (!await networkInfo.isConnected) {
       return Left(NetworkFailure());
     }
     try {
        final response = await apiCall();
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['code'] == 200) {
             try {
                return Right(dataMapper(jsonResponse['data']));
             } catch (e) {
                print("Error parsing data: $e");
                print("Response data: ${jsonResponse['data']}");
                return Left(ParsingFailure('Failed to parse server response data'));
             }
          } else {
             final errorMsg = jsonResponse['msg'] ?? 'Unknown server error';
              print("Server returned error code ${jsonResponse['code']}: $errorMsg");
             return Left(ServerFailure(errorMsg, code: jsonResponse['code']));
          }
        } else if (response.statusCode == 401 || response.statusCode == 403) {
           return Left(AuthenticationFailure('Unauthorized or Forbidden'));
        } else {
          print("HTTP Error ${response.statusCode}: ${response.body}");
           return Left(ServerFailure('Server error: ${response.statusCode}'));
        }
     } on SocketException {
        return Left(NetworkFailure('Failed to connect to the server'));
     } on FormatException {
        return Left(ParsingFailure('Failed to parse server response'));
     } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
     } catch (e) {
        print("Unhandled exception in _handleApiCall: $e");
        return Left(GenericFailure('An unexpected error occurred: ${e.toString()}'));
     }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUserInfo() async {
    final url = Uri.parse('$_apiBaseUrl/api/member/info');
    print("Calling GET $url");

    return _handleApiCall(
      () async => client.get(url, headers: await _getHeaders()),
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<ChatSessionModel>>> getChatSessions() async {
    final url = Uri.parse('$_apiBaseUrl/api/chat/list');
    print("Calling POST $url");

    return _handleApiCall(
      () async => client.post(url, headers: await _getHeaders(), body: json.encode({})), // Empty body as per spec
      (data) {
         final List<dynamic> rows = data['rows'] as List;
         return rows.map((sessionJson) => ChatSessionModel.fromJson(sessionJson as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId) async {
     final url = Uri.parse('$_apiBaseUrl/api/chat/message/list');
     final body = json.encode({'chatId': chatId});
     print("Calling POST $url with body: $body");

     return _handleApiCall(
       () async => client.post(url, headers: await _getHeaders(), body: body),
       (data) {
          final List<dynamic> rows = data['rows'] as List;
          return rows.map((msgJson) => MessageModel.fromJson(msgJson as Map<String, dynamic>)).toList();
       },
    );
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required int chatId,
    required String type,
    required String context,
  }) async {
     final url = Uri.parse('$_apiBaseUrl/common/chat/message/add');
     final body = json.encode({
       'chatId': chatId,
       'type': type,
       'context': context,
     });
      print("Calling POST $url with body: $body");

      return _handleApiCall(
         () async => client.post(url, headers: await _getHeaders(), body: body),
         (data) => MessageModel.fromJson(data as Map<String, dynamic>),
      );
  }

 @override
 Future<Either<Failure, void>> revokeMessage(int messageId) async {
    final url = Uri.parse('$_apiBaseUrl/api/chat/message/withdraw');
    final body = json.encode({'id': messageId});
    print("Calling POST $url with body: $body");

    return _handleApiCall(
       () async => client.post(url, headers: await _getHeaders(), body: body),
       (_) => unit, // Return Right(unit) on success
    );
 }

 @override
 Future<Either<Failure, int>> createChatSession(int targetUserId) async {
    final url = Uri.parse('$_apiBaseUrl/api/chat/addChat');
    // API expects doctorId, assuming targetUserId maps to doctorId here
    final body = json.encode({'doctorId': targetUserId.toString()}); 
     print("Calling POST $url with body: $body");

     return _handleApiCall(
        () async => client.post(url, headers: await _getHeaders(), body: body),
        (data) => data as int, // API returns chatId directly in data field
     );
 }

 @override
 Future<Either<Failure, String>> uploadFile(File file, {Function(double progress)? onProgress}) async {
    if (!await networkInfo.isConnected) {
       return Left(NetworkFailure());
    }
    final url = Uri.parse('$_apiBaseUrl/api/common/public/upload');
    print("Calling POST $url for file upload");

    try {
       // TODO: Use IHttpClient's multipart upload method
       // The following is a placeholder using the standard http package
       var request = http.MultipartRequest('POST', url);
       request.headers.addAll(await _getHeaders()..remove('Content-Type')); // Remove default json content-type
       request.files.add(await http.MultipartFile.fromPath(
          'file', // API likely expects the file under the key 'file'
          file.path,
          // TODO: Determine content type if needed by API
          // contentType: MediaType('image', 'jpeg'), 
        ));

       // TODO: Integrate progress callback with client's upload stream if possible
       final streamedResponse = await client.send(request);
       final response = await http.Response.fromStream(streamedResponse);

       if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
           if (jsonResponse['code'] == 200 && jsonResponse['data'] != null && jsonResponse['data'] is String) {
             return Right(jsonResponse['data'] as String); // Assuming data field contains the URL
           } else {
             final errorMsg = jsonResponse['msg'] ?? 'Upload failed with server code ${jsonResponse['code']}';
             print("Upload failed: $errorMsg");
             return Left(ServerFailure(errorMsg, code: jsonResponse['code']));
           }
       } else {
          print("Upload HTTP Error ${response.statusCode}: ${response.body}");
           return Left(ServerFailure('Upload failed: ${response.statusCode}'));
       }
    } on SocketException {
        return Left(NetworkFailure('Failed to connect for upload'));
    } catch (e) {
       print("Unhandled exception during upload: $e");
        return Left(GenericFailure('File upload failed: ${e.toString()}'));
    }
 }
}

// --- 假设的 Core 模块依赖 ---
nothing_here_yet() { }

// 假设的自定义异常
class ServerException implements Exception {
  final String message;
  final int? code;
  ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException(code: $code, message: $message)';
}

class AuthenticationException implements Exception {
   final String message;
  AuthenticationException({required this.message});
  @override
  String toString() => 'AuthenticationException(message: $message)';
}

class NetworkException implements Exception {
   final String message;
  NetworkException({required this.message});
  @override
  String toString() => 'NetworkException(message: $message)';
} 