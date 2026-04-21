import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

// Core Error Handling
import 'package:dskk_flutter_refactor/core/error/failures.dart'; 
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import core exceptions

// Domain Layer (Interfaces and Entities)
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_ai_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/chat_allocation_result_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/load_history_usecase.dart'; // 导入LoadHistoryResult
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_conversations_usecase.dart'; // 导入GetConversationsResult

// Data Layer (Data Sources and Models)
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/i_ai_chat_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/models/ai_chat_message_model.dart'; // 导入模型类
import 'package:dskk_flutter_refactor/features/ai_docs/data/models/ai_conversation_model.dart'; // 导入对话模型类

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// {@template ai_chat_repository_impl}
/// Implementation of [IAiChatRepository] that uses [IAiChatRemoteDataSource]
/// to fetch data from the backend and [IAiChatLocalDataSource] (if needed)
/// for local caching.
///
/// It translates API models to domain entities and handles exceptions from
/// data sources, converting them to domain [Failure] objects.
/// {@endtemplate}
@LazySingleton(as: IAiChatRepository)
class AiChatRepositoryImpl implements IAiChatRepository {
  final IAiChatRemoteDataSource _remoteDataSource;
  // Optional dependencies for future enhancements:
  // final INetworkInfo networkInfo; // For checking network status
  // final ILocalDataSource localDataSource; // For implementing caching

  /// {@macro ai_chat_repository_impl}
  AiChatRepositoryImpl({required IAiChatRemoteDataSource remoteDataSource}) 
      : _remoteDataSource = remoteDataSource;

  /// Helper function to execute a remote data source call safely.
  /// Handles specific data source exceptions and converts them to domain Failures.
  /// Wraps unexpected errors in GeneralFailure.
  Future<Either<Failure, T>> _tryCatch<T>(
    Future<T> Function() action,
  ) async {
    // If network info check is needed:
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure());
    // }

    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } on Exception catch (e) {
      AppLogger.d('Unexpected exception in AiChatRepository: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Stream<T>>> _tryCatchStream<T>(
      Future<Stream<T>> Function() streamAction) async {
    try {
      final stream = await streamAction();
      return Right(stream);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Cache error'));
    } on Exception catch (e) {
      AppLogger.d('Unexpected exception in AiChatRepository stream operation: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GetConversationsResult>> fetchConversations({
    required int userId,
    int page = 1,
    int pageSize = 20,
    String orderBy = 'desc',
  }) async {
    // Use the helper to wrap the data source call
    return _tryCatch<GetConversationsResult>(() async {
      final conversationsData = await _remoteDataSource.fetchConversations(
        userId: userId,
        page: page,
        pageSize: pageSize,
        orderBy: orderBy,
      );
      
      // 处理数据源返回的Map格式
      final conversationsListData = conversationsData['conversations'] as List? ?? [];
      final conversations = conversationsListData
          .cast<AiConversationModel>() // 将List<dynamic>转换为List<AiConversationModel>
          .map((model) => model.toEntity())
          .toList();
      
      // 构造GetConversationsResult实体
      return GetConversationsResult(
        conversations: conversations,
        hasMore: conversationsData['hasMore'] as bool? ?? false,
        currentPage: conversationsData['currentPage'] as int? ?? page,
        totalPages: conversationsData['totalPages'] as int? ?? 0,
        totalConversations: conversationsData['totalConversations'] as int? ?? conversations.length,
      );
    });
  }

  @override
  Future<Either<Failure, LoadHistoryResult>> loadHistory({
    required int conversationId,
    required int userId,
    int page = 1,
    int pageSize = 50,
    String orderBy = 'desc',
    bool getAll = false,
  }) async {
    return _tryCatch<LoadHistoryResult>(() async {
      final historyData = await _remoteDataSource.loadHistory(
        conversationId: conversationId,
        userId: userId,
        page: page,
        pageSize: pageSize,
        orderBy: orderBy,
        getAll: getAll,
      );
      
      // 处理数据源返回的Map格式
      final messagesData = historyData['messages'] as List? ?? [];
      final messages = messagesData
          .cast<AiChatMessageModel>() // 将List<dynamic>转换为List<AiChatMessageModel>
          .map((model) => model.toEntity())
          .toList();
      
      // 构造LoadHistoryResult实体
      return LoadHistoryResult(
        messages: messages,
        hasMore: historyData['hasMore'] as bool? ?? false,
        currentPage: historyData['currentPage'] as int? ?? page,
        totalPages: historyData['totalPages'] as int? ?? 0,
        totalMessages: historyData['totalMessages'] as int? ?? messages.length,
      );
    });
  }

  @override
  Future<Either<Failure, int>> createConversation(
      {required int userId, String? title}) async {
    // Use helper, result is primitive, no conversion needed
    return _tryCatch<int>(() async {
      return await _remoteDataSource.createConversation(userId: userId, title: title);
    });
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
      {required int conversationId, required int userId}) async {
    // Use helper, result is void
    return _tryCatch<void>(() async {
      await _remoteDataSource.deleteConversation(
        conversationId: conversationId,
        userId: userId,
      );
    });
  }

  @override
  Future<Either<Failure, Stream<String>>> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
    List<String>? audioUrls,
    String? transcription,
  }) async {
    return _tryCatchStream<String>(() async {
      return _remoteDataSource.streamChatCompletion(
        conversationId: conversationId,
        userId: userId,
        message: message,
        fileUrls: fileUrls,
        audioUrls: audioUrls,
        transcription: transcription,
      );
    });
  }

  @override
  Future<Either<Failure, List<RelatedServiceEntity>>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
    int? messageId,
  }) async {
    return _tryCatch<List<RelatedServiceEntity>>(() async {
      final servicesData = await _remoteDataSource.getRelatedServices(
        conversationId: conversationId,
        userId: userId,
        limit: limit,
        messageId: messageId,
      );
      return servicesData.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, ChatAllocationResultEntity>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item,
    required int merchantId,
  }) async {
    return _tryCatch<ChatAllocationResultEntity>(() async {
      final resultData = await _remoteDataSource.allocateChatResource(
        conversationId: conversationId,
        userId: userId,
        item: item,
        merchantId: merchantId,
      );
      // 假设服务器返回的数据需要转换为实体
      // 如果返回的是Map，手动构造实体
      return ChatAllocationResultEntity(
        summary: resultData['summary'] as String? ?? 'No summary available',
        merchantId: resultData['merchant_id'] as int? ?? 0,
        item: resultData['item'] as Map<String, dynamic>?,
      );
    });
  }

  @override
  Future<Either<Failure, String>> transcribeAudio(
      {required String audioOssUrl, int? userId}) async {
    // Use helper, return String result directly
     return _tryCatch<String>(() async {
      return await _remoteDataSource.transcribeAudio(
        audioOssUrl: audioOssUrl,
        userId: userId,
      );
    });
  }

  @override
  Future<Either<Failure, void>> cancelChatGeneration({
    required int conversationId,
    required int userId,
  }) async {
    return _tryCatch<void>(() async {
      await _remoteDataSource.cancelChatGeneration(
        conversationId: conversationId,
        userId: userId,
      );
    });
  }

  @override
  Future<Either<Failure, String>> updateConversationTitle({
    required int conversationId,
    required int userId,
    required String title,
  }) async {
    return _tryCatch<String>(() async {
      return await _remoteDataSource.updateConversationTitle(
        conversationId: conversationId,
        userId: userId,
        title: title,
      );
    });
  }

  @override
  Future<Either<Failure, String>> generateConversationTitle({
    required int conversationId,
    required int userId,
  }) async {
    return _tryCatch<String>(() async {
      return await _remoteDataSource.generateConversationTitle(
        conversationId: conversationId,
        userId: userId,
      );
    });
  }
} 