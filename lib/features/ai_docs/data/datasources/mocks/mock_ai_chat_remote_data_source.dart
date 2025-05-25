import 'dart:async';
import 'dart:math'; // For Random

import '../../models/ai_conversation_model.dart';
import '../../models/ai_chat_message_model.dart';
import '../../models/related_service_model.dart';
import '../i_ai_chat_remote_data_source.dart';
import '../../../domain/entities/ai_chat_message_entity.dart'; // For MessageSender enum

/// Mock implementation of [IAiChatRemoteDataSource] for testing and preview purposes.
///
/// Simulates network delays and provides predefined responses or errors.
class MockAiChatRemoteDataSource implements IAiChatRemoteDataSource {
  // Simulate network latency
  Future<void> _simulateDelay([int milliseconds = 500]) =>
      Future.delayed(Duration(milliseconds: milliseconds));

  bool _shouldFail = false; // Flag to toggle simulated failures
  final Random _random = Random();

  /// Sets whether the mock data source should simulate failures.
  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  @override
  Future<List<AiConversationModel>> fetchConversations({required int userId}) async {
    await _simulateDelay();
    if (_shouldFail) {
      throw Exception('Mock Network Error: Failed to fetch conversations.');
    }

    // Generate some mock conversations matching the actual constructor
    // Note: limit is not part of the interface, simulate a fixed number or all
    const mockTotalConversations = 25;
    return List.generate(mockTotalConversations, (index) {
      final id = index + 1;
      return AiConversationModel(
        conversationId: id, 
        title: 'Mock Conversation $id',
        updatedAtString: DateTime.now().subtract(Duration(minutes: index * 10)).toIso8601String(),
      );
    });
  }

  @override
  Future<List<AiChatMessageModel>> loadHistory({
    required int conversationId,
    required int userId,
    int? offset,
    int? limit,
  }) async {
    await _simulateDelay(800); 
     if (_shouldFail) {
      throw Exception('Mock Network Error: Failed to load history.');
    }
     if (conversationId < 1) { 
       print('Mock Warning: Called loadHistory with potentially invalid conversation ID: $conversationId');
       return []; 
     }

    final int effectiveOffset = offset ?? 0;
    final int effectiveLimit = limit ?? 20;

    final totalMessages = 45; 
    final startIndex = totalMessages - effectiveOffset - effectiveLimit;
    final endIndex = totalMessages - effectiveOffset;

    if (startIndex >= totalMessages) return [];

    return List.generate(max(0, endIndex - startIndex), (index) {
        final messageIndex = max(0, startIndex) + index;
        final isUserMessage = messageIndex % 2 == 0;
        final roleString = isUserMessage ? 'user' : 'assistant';
        final messageTimestamp = DateTime.now().subtract(Duration(hours: totalMessages - messageIndex));

        return AiChatMessageModel(
          messageId: (conversationId * 1000) + (messageIndex + 1),
          conversationId: conversationId,
          role: roleString, 
          content: 'This is mock message ${messageIndex + 1} for conversation $conversationId. ' +
                   (roleString == 'assistant' ? 'Lorem ipsum dolor sit amet.' : ''),
          timestamp: messageTimestamp.millisecondsSinceEpoch ~/ 1000,
        );
      }).toList();
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
    if (_shouldFail) {
       if(_random.nextBool()){
         return Stream.error(Exception('Mock SSE Error: Connection failed'));
       } else {
          final controller = StreamController<String>();
          Future.delayed(Duration(milliseconds: 150), () => controller.add("Partial mock..."))
                .then((_) => Future.delayed(Duration(milliseconds: 300)))
                .then((_) => controller.addError(Exception('Mock SSE Error: Failed mid-stream')));
          return controller.stream;
       }
    }
     if (conversationId < 1) {
       return Stream.error(Exception('Mock SSE Error: Invalid Conversation ID'));
     }

    final controller = StreamController<String>();
    String responseBase = "Mock response for '$message': Lorem ipsum dolor sit amet, consectetur adipiscing elit. ";
    
    if (fileUrls.isNotEmpty) {
      responseBase += 'Files received: ${fileUrls.join(', ')}. ';
    }
    
    if (audioUrls != null && audioUrls.isNotEmpty) {
      responseBase += 'Audio URLs received: ${audioUrls.join(', ')}. ';
    }
    
    if (transcription != null && transcription.isNotEmpty) {
      responseBase += 'Transcription received: $transcription. ';
    }
    
    responseBase += "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    
    final responseWords = responseBase.split(' ');
    int wordIndex = 0;

    Future.delayed(Duration(milliseconds: 100), () {
        Timer.periodic(Duration(milliseconds: _random.nextInt(150) + 50), (timer) {
        if (!controller.isClosed) {
             if (wordIndex < responseWords.length) {
            controller.add(responseWords[wordIndex] + ' ');
            wordIndex++;
            } else {
                timer.cancel();
                controller.close();
            }
        } else {
            timer.cancel();
        }
        });
    });

    return controller.stream;
  }

  @override
  Future<int> createConversation({
    required int userId,
    String? title,
  }) async {
    await _simulateDelay();
     if (_shouldFail) {
      throw Exception('Mock Network Error: Failed to create conversation.');
    }
    final effectiveTitle = title ?? 'New Mock Conversation';
    print('Mock: Conversation "$effectiveTitle" created for user $userId.');
    final newId = _random.nextInt(1000) + 100; 
    return newId;
  }

   @override
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  }) async {
    await _simulateDelay();
    if (_shouldFail) {
      throw Exception('Mock Network Error: Failed to delete conversation.');
    }
    if (conversationId < 1) {
      throw Exception('Mock Error: Cannot delete invalid conversation ID');
    }
    print('Mock: Conversation $conversationId deleted for user $userId.');
  }

  @override
  Future<List<RelatedServiceModel>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
    int? messageId,
  }) async {
     await _simulateDelay(600);
      if (_shouldFail) {
        throw Exception('Mock Network Error: Failed to get recommendations.');
      }
      final effectiveLimit = limit ?? 5;
      
      // 记录messageId的使用，方便调试
      if (messageId != null) {
        print('Mock: Getting recommendations for message $messageId in conversation $conversationId');
      }

     return List.generate(effectiveLimit, (i) => RelatedServiceModel(
       id: _random.nextInt(10000) + 1, 
       imageUrl: 'https://via.placeholder.com/150/service_$i.png', 
       title: 'Related Service ${i+1}', 
       price: (_random.nextDouble() * 50 + 10).roundToDouble(), 
     ));
  }

  @override
  Future<Map<String, dynamic>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item,
    required int merchantId,
  }) async {
     await _simulateDelay(1200); 
     if (_shouldFail) {
        throw Exception('Mock Network Error: Failed to allocate resource.');
      }
      print('Mock: Allocating resource for item ${item['name'] ?? 'unknown'} in conversation $conversationId, merchant $merchantId');
      return {
        'success': true,
        'message': 'Mock resource allocated successfully.',
        'merchant_id': merchantId,
        'item': item,
      };
  }

   @override
  Future<String> transcribeAudio({
    required String audioOssUrl,
    int? userId,
   }) async {
      await _simulateDelay(1500); 
       if (_shouldFail) {
        throw Exception('Mock Network Error: Failed to transcribe audio.');
      }
       if (!audioOssUrl.contains('mock-audio')) { 
         print('Mock Warning: transcribeAudio called with potentially unexpected URL: $audioOssUrl');
       }
       print('Mock: Transcribing audio from $audioOssUrl for user ${userId ?? 'unknown'}.');
       return "This is the mock transcription result for the audio file located at $audioOssUrl. It might contain pauses... or specific keywords.";
  }

  @override
  Future<void> cancelChatGeneration({
    required int conversationId,
    required int userId,
  }) async {
    await _simulateDelay(300);
    if (_shouldFail) {
      throw Exception('Mock Network Error: Failed to cancel chat generation.');
    }
    if (conversationId < 1) {
      throw Exception('Mock Error: Cannot cancel chat generation for invalid conversation ID');
    }
    print('Mock: Chat generation cancelled for conversation $conversationId, user $userId.');
  }

}
