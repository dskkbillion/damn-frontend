// import '../datasources/i_ai_chat_remote_data_source.dart'; // Ensure this import is correct if used

// Temporarily comment out injectable annotation to avoid build errors
// @LazySingleton(as: IAiChatRepository) // Example annotation, adjust if different
class AiChatRepositoryImpl implements IAiChatRepository {
  final IAiChatRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  // Optional dependencies for future enhancements:
  // final INetworkInfo networkInfo; // For checking network status
  // final ILocalDataSource localDataSource; // For implementing caching

  /// {@macro ai_chat_repository_impl}
  AiChatRepositoryImpl(this._remoteDataSource, this._networkInfo);

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
      return Left(GeneralFailure(message: 'Data source error: ${e.message}'));
    } catch (e, stacktrace) {
      // Catch any other unexpected errors
      print('Unexpected error in Repository: $e\n$stacktrace');
      return Left(GeneralFailure(message: 'An unexpected error occurred: ${e.toString()}'));
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
      return Left(GeneralFailure(message: 'Data source error initiating stream: ${e.message}'));
    } catch (e, stacktrace) {
       print('Unexpected error initiating streamChatCompletion: $e\n$stacktrace');
      return Left(GeneralFailure(message: 'An unexpected error occurred initiating stream: ${e.toString()}'));
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

  @override
  Future<Either<Failure, List<AiChatEntry>>> getAiChatHistory(String userId) async {
     if (await _networkInfo.isConnected) {
       try {
         final remoteHistory = await _remoteDataSource.getAiChatHistory(userId);
         // TODO: Cache the history locally if needed
         // localDataSource.cacheAiChatHistory(remoteHistory);
         return Right(remoteHistory.map((model) => model.toEntity()).toList());
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
         print('getAiChatHistory Unexpected Exception: $e');
         return Left(ServerFailure(message: e.toString()));
       }
     } else {
       // TODO: Load from cache if offline
       // try {
       //   final localHistory = await localDataSource.getLastAiChatHistory();
       //   return Right(localHistory.map((model) => model.toEntity()).toList());
       // } on CacheException {
       //   return Left(CacheFailure());
       // }
       return Left(const NetworkFailure()); // Return NetworkFailure
     }
  }

   @override
   Future<Either<Failure, String>> sendToAi(String sessionId, String message, String userId) async {
      if (await _networkInfo.isConnected) {
       try {
         final result = await _remoteDataSource.sendToAi(sessionId, message, userId);
         return Right(result);
       } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
         print('sendToAi Unexpected Exception: $e');
         return Left(ServerFailure(message: e.toString()));
       }
     } else {
        return Left(const NetworkFailure()); // Return NetworkFailure
     }
   }

   @override
   Stream<Either<Failure, String>> streamAiResponse(String sessionId) async* {
      if (await _networkInfo.isConnected) {
       try {
         final stream = _remoteDataSource.streamAiResponse(sessionId);
         await for (final chunk in stream) {
           yield Right(chunk);
         }
       } on ServerException catch (e) {
          yield Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
         print('streamAiResponse Unexpected Exception: $e');
         yield Left(ServerFailure(message: e.toString()));
       }
     } else {
        yield Left(const NetworkFailure()); // Return NetworkFailure
     }
   }


   @override
   Future<Either<Failure, AiChatSetting>> getAiChatSetting(String userId) async {
      if (await _networkInfo.isConnected) {
       try {
         final remoteSetting = await _remoteDataSource.getAiChatSetting(userId);
         return Right(remoteSetting.toEntity());
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
          print('getAiChatSetting Unexpected Exception: $e');
          return Left(ServerFailure(message: e.toString()));
       }
     } else {
        return Left(const NetworkFailure()); // Use NetworkFailure
     }
   }

   @override
   Future<Either<Failure, Unit>> saveAiChatSetting(String userId, AiChatSetting setting) async {
      if (await _networkInfo.isConnected) {
       try {
         await _remoteDataSource.saveAiChatSetting(userId, AiChatSettingModel.fromEntity(setting));
         return const Right(unit);
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
         print('saveAiChatSetting Unexpected Exception: $e');
         return Left(ServerFailure(message: e.toString()));
       }
     } else {
        return Left(const NetworkFailure()); // Use NetworkFailure
     }
   }

    @override
    Future<Either<Failure, Unit>> deleteAiChatHistory(String sessionId) async {
       if (await _networkInfo.isConnected) {
       try {
         await _remoteDataSource.deleteAiChatHistory(sessionId);
         return const Right(unit);
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
         print('deleteAiChatHistory Unexpected Exception: $e');
         return Left(ServerFailure(message: e.toString()));
       }
     } else {
        return Left(const NetworkFailure()); // Use NetworkFailure
     }
    }

    @override
    Future<Either<Failure, Unit>> clearAllAiChatHistory(String userId) async {
       if (await _networkInfo.isConnected) {
       try {
         await _remoteDataSource.clearAllAiChatHistory(userId);
         return const Right(unit);
       } on ServerException catch (e) {
         return Left(ServerFailure(message: e.message, code: e.statusCode)); // Use statusCode
       } on Exception catch (e) {
          print('clearAllAiChatHistory Unexpected Exception: $e');
          return Left(ServerFailure(message: e.toString()));
       }
     } else {
        return Left(const NetworkFailure()); // Use NetworkFailure
     }
    }

    @override
    Stream<Either<Failure, AiChatEntry>> streamChatCompletion(String message, String conversationId, String? parentMessageId) {
      return Stream.value(Left(GeneralFailure(message: "AI Chat feature temporarily disabled")));
    }
} 