import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatMessage message(String type, String context) => ChatMessage(
        id: 1,
        chatId: 2,
        senderId: 3,
        type: type,
        context: context,
        createTime: DateTime(2026, 7, 21),
        withdrawFlag: false,
      );

  test('recognizes historical Agent request text envelopes', () {
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message(
          'text',
          '[DeepStream request #7] 7 天工作节奏调整方案\n\n需求正文',
        ),
      ),
      isTrue,
    );
  });

  test('does not reclassify ordinary text or malformed request labels', () {
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message('text', '请看一下 [DeepStream request #7]'),
      ),
      isFalse,
    );
    expect(
      ChatMessageBubble.isLegacyAgentRequestMessage(
        message('text', '[DeepStream request #x] 普通文本'),
      ),
      isFalse,
    );
  });
}
