import 'dart:convert';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';

/// Adapter for converting between domain entities and flutter_chat_ui types
class ChatMessageAdapter {
  /// Convert domain ChatMessage to flutter_chat_ui Message
  static types.Message toUiMessage(
    ChatMessage message,
    Participant sender, {
    int currentUserId = 0,
  }) {
    final author = toUiUser(sender);
    
    switch (message.type) {
      case 'text':
        return types.TextMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          text: message.context,
          status: _toUiStatus(message.status),
          metadata: {
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
          },
        );
        
      case 'image':
        // Parse image URL from context
        String imageUrl = message.context;
        Map<String, dynamic>? imageData;
        
        try {
          // Try to parse as JSON first (might contain metadata)
          imageData = jsonDecode(message.context);
          imageUrl = imageData['url'] ?? message.context;
        } catch (_) {
          // If not JSON, use context as URL directly
        }
        
        return types.ImageMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          name: imageData?['name'] ?? 'image',
          size: imageData?['size'] ?? 0,
          uri: imageUrl,
          status: _toUiStatus(message.status),
          metadata: {
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
            'originalData': imageData,
          },
        );
        
      case 'audio':
        // Parse audio data from context
        Map<String, dynamic>? audioData;
        String audioUrl = message.context;
        
        try {
          audioData = jsonDecode(message.context);
          audioUrl = audioData['url'] ?? message.context;
        } catch (_) {
          // If not JSON, use context as URL directly
        }
        
        return types.AudioMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          duration: Duration(seconds: audioData?['duration'] ?? 0),
          name: audioData?['name'] ?? 'audio',
          size: audioData?['size'] ?? 0,
          uri: audioUrl,
          status: _toUiStatus(message.status),
          metadata: {
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
            'originalData': audioData,
          },
        );
        
      case 'file':
        // Parse file data from context
        Map<String, dynamic>? fileData;
        String fileUrl = message.context;
        
        try {
          fileData = jsonDecode(message.context);
          fileUrl = fileData['url'] ?? message.context;
        } catch (_) {
          // If not JSON, use context as URL directly
        }
        
        return types.FileMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          name: fileData?['name'] ?? 'file',
          size: fileData?['size'] ?? 0,
          uri: fileUrl,
          status: _toUiStatus(message.status),
          metadata: {
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
            'originalData': fileData,
          },
        );
        
      case 'allocate':
        // Custom allocate message type
        Map<String, dynamic>? allocateData;
        
        try {
          allocateData = jsonDecode(message.context);
        } catch (_) {
          allocateData = {'content': message.context};
        }
        
        return types.CustomMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          metadata: {
            'type': 'allocate',
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
            'allocateData': allocateData,
            'originalContext': message.context,
          },
          status: _toUiStatus(message.status),
        );
        
      case 'revoke':
        // Withdrawn message
        return types.TextMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          text: '消息已撤回',
          status: _toUiStatus(message.status),
          metadata: {
            'type': 'revoke',
            'withdrawFlag': true,
            'readFlg': message.readFlg,
          },
        );
        
      default:
        // Unknown type, treat as text
        return types.TextMessage(
          author: author,
          createdAt: message.createTime.millisecondsSinceEpoch,
          id: message.id.toString(),
          text: message.context,
          status: _toUiStatus(message.status),
          metadata: {
            'type': message.type,
            'withdrawFlag': message.withdrawFlag,
            'readFlg': message.readFlg,
          },
        );
    }
  }
  
  /// Convert flutter_chat_ui Message to domain ChatMessage
  static ChatMessage toDomainMessage(
    types.Message uiMessage,
    int chatId,
    int senderId, {
    int? memberId,
    int? doctorId,
  }) {
    String context = '';
    String type = 'text';
    
    if (uiMessage is types.TextMessage) {
      context = uiMessage.text;
      type = uiMessage.metadata?['type'] ?? 'text';
    } else if (uiMessage is types.ImageMessage) {
      // Store image data as JSON
      context = jsonEncode({
        'url': uiMessage.uri,
        'name': uiMessage.name,
        'size': uiMessage.size,
      });
      type = 'image';
    } else if (uiMessage is types.AudioMessage) {
      // Store audio data as JSON
      context = jsonEncode({
        'url': uiMessage.uri,
        'name': uiMessage.name,
        'size': uiMessage.size,
        'duration': uiMessage.duration.inSeconds,
      });
      type = 'audio';
    } else if (uiMessage is types.FileMessage) {
      // Store file data as JSON
      context = jsonEncode({
        'url': uiMessage.uri,
        'name': uiMessage.name,
        'size': uiMessage.size,
      });
      type = 'file';
    } else if (uiMessage is types.CustomMessage) {
      // Handle custom messages
      final metadata = uiMessage.metadata ?? {};
      if (metadata['type'] == 'allocate') {
        context = metadata['originalContext'] ?? jsonEncode(metadata['allocateData']);
        type = 'allocate';
      } else {
        context = jsonEncode(metadata);
        type = metadata['type'] ?? 'custom';
      }
    }
    
    return ChatMessage(
      id: int.tryParse(uiMessage.id) ?? 0,
      chatId: chatId,
      senderId: senderId,
      memberId: memberId,
      doctorId: doctorId,
      context: context,
      type: type,
      createTime: DateTime.fromMillisecondsSinceEpoch(uiMessage.createdAt ?? 0),
      withdrawFlag: uiMessage.metadata?['withdrawFlag'] ?? false,
      readFlg: uiMessage.metadata?['readFlg'],
      status: _toDomainStatus(uiMessage.status),
    );
  }
  
  /// Convert Participant to flutter_chat_ui User
  static types.User toUiUser(Participant participant) {
    return types.User(
      id: participant.referId?.toString() ?? participant.id.toString(),
      firstName: participant.nickName,
      imageUrl: participant.avatar,
      metadata: {
        'type': participant.type,
        'participantId': participant.id,
        'referId': participant.referId,
      },
    );
  }
  
  /// Convert flutter_chat_ui User to Participant
  static Participant toDomainParticipant(types.User user) {
    final metadata = user.metadata ?? {};
    return Participant(
      id: metadata['participantId'] ?? int.tryParse(user.id) ?? 0,
      nickName: user.firstName,
      avatar: user.imageUrl,
      type: metadata['type'],
      referId: metadata['referId'] ?? int.tryParse(user.id),
    );
  }
  
  /// Convert domain MessageStatus to UI Status
  static types.Status? _toUiStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return types.Status.sending;
      case MessageStatus.sent:
        return types.Status.sent;
      case MessageStatus.failed:
        return types.Status.error;
      case MessageStatus.read:
        return types.Status.seen;
    }
  }
  
  /// Convert UI Status to domain MessageStatus
  static MessageStatus _toDomainStatus(types.Status? status) {
    if (status == null) return MessageStatus.sent;
    
    switch (status) {
      case types.Status.sending:
        return MessageStatus.sending;
      case types.Status.sent:
        return MessageStatus.sent;
      case types.Status.error:
        return MessageStatus.failed;
      case types.Status.seen:
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
  
  /// Create an allocate message for product allocation
  static types.CustomMessage createAllocateMessage({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    required String allocationType,
    required Participant sender,
    DateTime? createTime,
  }) {
    final allocateData = {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'allocationType': allocationType,
    };
    
    return types.CustomMessage(
      author: toUiUser(sender),
      createdAt: (createTime ?? DateTime.now()).millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      metadata: {
        'type': 'allocate',
        'allocateData': allocateData,
        'originalContext': jsonEncode(allocateData),
      },
    );
  }
  
  /// Check if a message is withdrawn
  static bool isWithdrawn(types.Message message) {
    return message.metadata?['withdrawFlag'] == true ||
           message.metadata?['type'] == 'revoke';
  }
  
  /// Check if a message is an allocate message
  static bool isAllocateMessage(types.Message message) {
    return message.metadata?['type'] == 'allocate';
  }
  
  /// Get allocate data from a custom message
  static Map<String, dynamic>? getAllocateData(types.Message message) {
    if (message is types.CustomMessage && isAllocateMessage(message)) {
      return message.metadata?['allocateData'] as Map<String, dynamic>?;
    }
    return null;
  }
}