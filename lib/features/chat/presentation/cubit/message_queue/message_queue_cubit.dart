import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/core/database/app_database.dart';
import 'package:dskk_flutter_refactor/features/chat/data/data_sources/local/chat_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';

part 'message_queue_state.dart';
part 'message_queue_cubit.freezed.dart';

/// Cubit for managing offline message queue
class MessageQueueCubit extends Cubit<MessageQueueState> {
  final IChatLocalDataSource _localDataSource;
  final SendMessage _sendMessage;
  
  StreamSubscription? _queueSubscription;
  Timer? _processTimer;
  bool _isProcessing = false;
  
  MessageQueueCubit({
    required IChatLocalDataSource localDataSource,
    required SendMessage sendMessage,
  })  : _localDataSource = localDataSource,
        _sendMessage = sendMessage,
        super(const MessageQueueState.idle());
  
  /// Initialize the queue and start monitoring
  Future<void> initialize() async {
    // Load existing queue items
    await _loadQueueItems();
    
    // Watch for queue changes
    _queueSubscription = _localDataSource.watchPendingMessages().listen((items) {
      emit(MessageQueueState.idle(
        queueItems: items,
        queueSize: items.length,
      ));
      
      // Start processing if there are items and we're not already processing
      if (items.isNotEmpty && !_isProcessing) {
        _startProcessing();
      }
    });
  }
  
  /// Load queue items
  Future<void> _loadQueueItems() async {
    final items = await _localDataSource.getPendingMessages();
    emit(MessageQueueState.idle(
      queueItems: items,
      queueSize: items.length,
    ));
  }
  
  /// Add a message to the queue
  Future<void> addToQueue({
    required int chatId,
    required String content,
    required String messageType,
  }) async {
    await _localDataSource.addToQueue(chatId, content, messageType);
  }
  
  /// Start processing the queue
  void _startProcessing() {
    if (_isProcessing) return;
    
    _isProcessing = true;
    emit(const MessageQueueState.processing());
    
    // Process queue items periodically
    _processTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _processNextItem();
    });
    
    // Process immediately
    _processNextItem();
  }
  
  /// Process the next item in the queue
  Future<void> _processNextItem() async {
    final items = await _localDataSource.getPendingMessages();
    
    if (items.isEmpty) {
      _stopProcessing();
      return;
    }
    
    final item = items.first;
    
    // Update status to sending
    await _localDataSource.updateQueueItemStatus(item.id, 'sending');
    
    // Try to send the message
    final result = await _sendMessage(
      SendMessageParams(
        message: ChatMessage(
          id: 0, // Will be assigned by server
          chatId: item.chatId,
          senderId: 0, // Will be set from auth context
          context: item.content,
          type: item.messageType,
          createTime: item.createdAt,
          withdrawFlag: false,
        ),
      ),
    );
    
    result.fold(
      (failure) async {
        // Increment retry count
        await _localDataSource.incrementRetryCount(item.id);
        
        // Check if max retries reached
        if (item.retryCount >= item.maxRetries - 1) {
          await _localDataSource.updateQueueItemStatus(
            item.id,
            'failed',
            errorMessage: failure.toString(),
          );
          emit(MessageQueueState.error(
            'Failed to send message after ${item.maxRetries} attempts',
          ));
        } else {
          // Update status back to pending for retry
          await _localDataSource.updateQueueItemStatus(item.id, 'pending');
        }
      },
      (_) async {
        // Remove from queue on success
        await _localDataSource.removeFromQueue(item.id);
        emit(MessageQueueState.itemSent(remainingItems: items.length - 1));
      },
    );
  }
  
  /// Stop processing the queue
  void _stopProcessing() {
    _isProcessing = false;
    _processTimer?.cancel();
    _processTimer = null;
    emit(const MessageQueueState.idle());
  }
  
  /// Add a message to the queue
  Future<void> addMessage(ChatMessage message) async {
    // Add message to local queue using the 3-parameter method
    await _localDataSource.addToQueue(
      message.chatId,
      message.context,
      message.type,
    );
    
    // Start processing if not already running
    if (!_isProcessing) {
      _startProcessing();
    }
  }
  
  /// Retry all failed messages
  Future<void> retryFailedMessages() async {
    // Reset status of failed messages to pending
    final items = await _localDataSource.getPendingMessages();
    for (final item in items.where((i) => i.status == 'failed')) {
      await _localDataSource.updateQueueItemStatus(item.id, 'pending');
    }
    
    if (!_isProcessing) {
      _startProcessing();
    }
  }
  
  /// Clear all failed messages
  Future<void> clearFailedMessages() async {
    await _localDataSource.clearFailedMessages();
    await _loadQueueItems();
  }
  
  /// Pause queue processing
  void pauseProcessing() {
    _stopProcessing();
    emit(const MessageQueueState.paused());
  }
  
  /// Resume queue processing
  void resumeProcessing() {
    if (!_isProcessing) {
      _startProcessing();
    }
  }
  
  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    _processTimer?.cancel();
    return super.close();
  }
}