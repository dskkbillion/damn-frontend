import 'dart:async';

// Core Error Handling
import 'package:dskk_flutter_refactor/core/error/failures.dart'; 
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Import core exceptions

// Domain Layer (Interfaces and Entities)
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_ai_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_conversation_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/chat_allocation_result_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart';

// Data Layer (Data Sources)
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/i_ai_chat_remote_data_source.dart';

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
      print('Unexpected exception in AiChatRepository: $e');
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
      print('Unexpected exception in AiChatRepository stream operation: $e');
      return Left(ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AiConversationEntity>>> fetchConversations(
      {required int userId}) async {
    // Use the helper to wrap the data source call
    return _tryCatch<List<AiConversationEntity>>(() async {
      final conversationsData = await _remoteDataSource.fetchConversations(userId: userId);
      // Map data model to entities
      return conversationsData.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<AiChatMessageEntity>>> loadHistory({
    required int conversationId,
    required int userId,
    int? offset,
    int? limit,
  }) async {
    return _tryCatch<List<AiChatMessageEntity>>(() async {
      final messagesData = await _remoteDataSource.loadHistory(
        conversationId: conversationId,
        userId: userId,
        offset: offset,
        limit: limit,
      );
      return messagesData.map((model) => model.toEntity()).toList();
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
  }) async {
    return _tryCatchStream<String>(() async {
      return _remoteDataSource.streamChatCompletion(
        conversationId: conversationId,
        userId: userId,
        message: message,
        fileUrls: fileUrls,
      );
    });
  }

  @override
  Future<Either<Failure, List<RelatedServiceEntity>>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
  }) async {
    return _tryCatch<List<RelatedServiceEntity>>(() async {
      final servicesData = await _remoteDataSource.getRelatedServices(
        conversationId: conversationId,
        userId: userId,
        limit: limit,
      );
      return servicesData.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, ChatAllocationResultEntity>> allocateChatResource({
    required int conversationId,
    required int userId,
    // TODO: Confirm actual request parameters
    required Map<String, dynamic> item,
    required int limit,
    required double similarityThreshold,
  }) async {
    return _tryCatch<ChatAllocationResultEntity>(() async {
      final resultData = await _remoteDataSource.allocateChatResource(
        conversationId: conversationId,
        userId: userId,
        item: item,
        limit: limit,
        similarityThreshold: similarityThreshold,
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
} 