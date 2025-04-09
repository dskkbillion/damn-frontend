import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';
// Ensure core network exceptions are importable if needed, though handled by datasource exceptions here
// import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ai_chat_message_entity.dart';
import '../../domain/entities/ai_conversation_entity.dart';
import '../../domain/entities/chat_allocation_result_entity.dart';
import '../../domain/entities/related_service_entity.dart';
import '../../domain/repositories/i_ai_chat_repository.dart';
import '../datasources/exceptions.dart' as ds_exceptions; // DataSource exceptions
import '../datasources/i_ai_chat_remote_data_source.dart';

/// {@template ai_chat_repository_impl}
/// Implementation of [IAiChatRepository] that uses [IAiChatRemoteDataSource]
/// to fetch data and converts data models to domain entities.
/// It also handles exceptions and maps them to domain [Failure] types.
/// {@endtemplate}
@LazySingleton(as: IAiChatRepository) // Annotate for DI
class AiChatRepositoryImpl implements IAiChatRepository {
  final IAiChatRemoteDataSource _remoteDataSource;
  // Optional dependencies for future enhancements:
  // final INetworkInfo networkInfo; // For checking network status
  // final ILocalDataSource localDataSource; // For implementing caching

  /// {@macro ai_chat_repository_impl}
  AiChatRepositoryImpl(this._remoteDataSource);

  /// Helper function to execute a remote data source call safely.
  /// Handles specific data source exceptions and converts them to domain Failures.
  /// Wraps unexpected errors in GeneralFailure.
  Future<Either<Failure, T>> _tryCatch<T>(
    Future<T> Function() action,
  ) async {
    // If network info check is needed:
    // if (!await networkInfo.isConnected) {
    //   return Left(NetworkFailure(message: 'No internet connection'));
    // }
    try {
      final result = await action();
      return Right(result);
    } on ds_exceptions.ServerException catch (e) {
      // Map ServerException from data source to ServerFailure for the domain
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ds_exceptions.NetworkException catch (e) {
      // Map NetworkException from data source to NetworkFailure for the domain
      return Left(NetworkFailure(message: e.message));
    } on ds_exceptions.DataSourceException catch (e) {
      // Map generic DataSourceException to a GeneralFailure
      print('DataSourceException in Repository: ${e.message}');
      return Left(UnknownFailure(message: 'Data source error: ${e.message}'));
    } catch (e, stacktrace) {
      // Catch any other unexpected errors
      print('Unexpected error in Repository: $e\n$stacktrace');
      return Left(UnknownFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AiConversationEntity>>> fetchConversations(
      {required int userId}) async {
    // Use the helper to wrap the data source call
    return _tryCatch<List<AiConversationEntity>>(() async {
      // Call the remote data source
      final models = await _remoteDataSource.fetchConversations(userId: userId);
      // Convert the list of models to a list of entities
      return models.map((model) => model.toEntity()).toList();
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
       final models = await _remoteDataSource.loadHistory(
         conversationId: conversationId,
         userId: userId,
         offset: offset,
         limit: limit,
       );
       // Convert models to entities
       return models.map((model) => model.toEntity()).toList();
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
       // The await ensures the future completes or throws before _tryCatch proceeds
       await _remoteDataSource.deleteConversation(
         conversationId: conversationId,
         userId: userId,
       );
       // No explicit return needed for void with _tryCatch Right side
    });
  }

  @override
  Future<Either<Failure, Stream<String>>> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
  }) async {
    // Streaming needs slightly different handling as the action itself returns the stream.
    // Errors during stream *initiation* are caught here.
    // Errors *during* streaming are handled by the stream consumer.
    try {
      // Directly call the data source method which should return the stream.
      final stream = _remoteDataSource.streamChatCompletion(
          conversationId: conversationId,
          userId: userId,
          message: message,
          fileUrls: fileUrls);
      // If the call succeeds, return the stream wrapped in Right.
      return Right(stream);
    } on ds_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ds_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ds_exceptions.DataSourceException catch (e) {
      print('DataSourceException initiating stream: ${e.message}');
      return Left(UnknownFailure(message: 'Data source error initiating stream: ${e.message}'));
    } catch (e, stacktrace) {
       print('Unexpected error initiating streamChatCompletion: $e\n$stacktrace');
      return Left(UnknownFailure(message: 'An unexpected error occurred initiating stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RelatedServiceEntity>>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
  }) async {
     return _tryCatch<List<RelatedServiceEntity>>(() async {
       final models = await _remoteDataSource.getRelatedServices(
         conversationId: conversationId,
         userId: userId,
         limit: limit,
       );
       // Convert models to entities
       return models.map((model) => model.toEntity()).toList();
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
     // Use helper, parse the Map result into an Entity
     return _tryCatch<ChatAllocationResultEntity>(() async {
       final resultMap = await _remoteDataSource.allocateChatResource(
         conversationId: conversationId,
         userId: userId,
         item: item,
         limit: limit,
         similarityThreshold: similarityThreshold,
       );
       // Manual parsing of the Map into the Entity
       // Add error handling for potentially missing keys if needed
       return ChatAllocationResultEntity(
         summary: resultMap['summary'] as String? ?? 'No summary provided',
         merchantId: resultMap['merchant_id'] as int? ?? 0, // Provide default or handle error
         item: resultMap['item'] as Map<String, dynamic>?, // Allow null item
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
