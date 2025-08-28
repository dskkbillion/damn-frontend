import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/cubit/message_list/message_list_cubit.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/payment_prompt_bubble.dart';

class MockChatTestPage extends StatefulWidget {
  const MockChatTestPage({super.key});

  @override
  State<MockChatTestPage> createState() => _MockChatTestPageState();
}

class _MockChatTestPageState extends State<MockChatTestPage> {
  static const int _mockChatId = -999; // Mock聊天室特殊ID
  static const String _promptCountKey = 'payment_prompt_count_mock_chat';
  
  int _roundCount = 0;
  int _promptCount = 0;
  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  // 付费提示消息池（与MessageListCubit中一致）
  static const List<String> _paymentPromptMessages = [
    "如果您对这次咨询感兴趣，可以选择付费支持获得更深入的交流",
    "想要了解更多？选择合适的服务套餐继续深入交流",
    "觉得有帮助吗？付费支持可以获得更专业的咨询服务",
    "感兴趣的话，可以选择付费获得持续的专业指导",
    "如果需要更详细的建议，欢迎选择付费支持",
    "想要深入探讨？选择服务套餐获得更全面的咨询",
    "对话很愉快！付费后可以获得更多专业建议",
    "希望继续交流？选择合适的套餐支持专业服务",
  ];
  
  @override
  void initState() {
    super.initState();
    _loadPromptCount();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // 加载已显示的付费提示次数
  Future<void> _loadPromptCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_promptCountKey) ?? 0;
    setState(() {
      _promptCount = count;
    });
  }
  
  // 保存付费提示次数
  Future<void> _savePromptCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_promptCountKey, count);
    setState(() {
      _promptCount = count;
    });
  }
  
  // 测试控制面板
  Widget _buildTestControlPanel() {
    final s = S.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.amber.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '测试控制面板',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPromptStatus(),
          const SizedBox(height: 12),
          Text('当前轮次: $_roundCount', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildControlButton('+1轮', () => _addRounds(1), Colors.blue),
              _buildControlButton('+5轮', () => _addRounds(5), Colors.blue),
              _buildControlButton('跳到第5轮', () => _jumpToRound(5), Colors.green),
              _buildControlButton('跳到第10轮', () => _jumpToRound(10), Colors.green),
              _buildControlButton('跳到第20轮', () => _jumpToRound(20), Colors.green),
              _buildControlButton('重置测试', _resetTest, Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建控制按钮
  Widget _buildControlButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
  
  // 付费提示状态显示
  Widget _buildPromptStatus() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('付费提示状态：', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          _buildStatusLine(5, '第5轮'),
          _buildStatusLine(10, '第10轮'),
          _buildStatusLine(20, '第20轮'),
          if (_promptCount >= 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: const [
                  Icon(Icons.block, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text('已达上限，不再提示', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建状态行
  Widget _buildStatusLine(int targetRound, String label) {
    final isTriggered = _hasPromptBeenShownForRound(targetRound);
    final canTrigger = _canShowPromptForRound(targetRound);
    final color = isTriggered 
        ? Colors.green 
        : (canTrigger && _roundCount >= targetRound) 
            ? Colors.orange 
            : Colors.grey;
    final icon = isTriggered 
        ? Icons.check_circle 
        : (canTrigger && _roundCount >= targetRound) 
            ? Icons.pending 
            : Icons.circle_outlined;
    final status = isTriggered 
        ? "已触发" 
        : (_roundCount >= targetRound ? "可触发" : "未到达");
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label - $status',
            style: TextStyle(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
  
  // 检查某轮次是否已显示过提示
  bool _hasPromptBeenShownForRound(int round) {
    if (round == 5 && _promptCount >= 1) return true;
    if (round == 10 && _promptCount >= 2) return true;
    if (round == 20 && _promptCount >= 3) return true;
    return false;
  }
  
  // 检查是否可以为某轮次显示提示
  bool _canShowPromptForRound(int round) {
    if (_promptCount >= 3) return false;
    if (round == 5 && _promptCount == 0) return true;
    if (round == 10 && _promptCount == 1) return true;
    if (round == 20 && _promptCount == 2) return true;
    return false;
  }
  
  // 模拟添加对话轮次
  void _addRounds(int rounds) {
    for (int i = 0; i < rounds; i++) {
      final roundNum = _roundCount + i + 1;
      
      // 添加买家消息
      _messages.add(ChatMessage(
        id: _messages.length + 1,
        chatId: _mockChatId,
        senderId: 1, // 买家ID
        context: '买家消息 #$roundNum：这是一个模拟的问题，用于测试付费提示功能。',
        createTime: DateTime.now().add(Duration(seconds: _messages.length * 2)),
        type: 'text',
        withdrawFlag: false,
        status: MessageStatus.read,
      ));
      
      // 添加卖家消息
      _messages.add(ChatMessage(
        id: _messages.length + 1,
        chatId: _mockChatId,
        senderId: 2, // 卖家ID
        context: '卖家回复 #$roundNum：这是一个模拟的回答，详细解答了您的问题。',
        createTime: DateTime.now().add(Duration(seconds: _messages.length * 2)),
        type: 'text',
        withdrawFlag: false,
        status: MessageStatus.read,
      ));
    }
    
    setState(() {
      _roundCount += rounds;
    });
    
    // 触发付费提示检查
    _checkPaymentPrompt();
    
    // 滚动到底部
    _scrollToBottom();
  }
  
  // 直接跳转到指定轮次
  void _jumpToRound(int targetRound) {
    if (targetRound <= _roundCount) return;
    
    final roundsToAdd = targetRound - _roundCount;
    _addRounds(roundsToAdd);
  }
  
  // 检查并插入付费提示
  void _checkPaymentPrompt() {
    // 已显示3次，不再提醒
    if (_promptCount >= 3) return;
    
    // 判断是否触发
    bool shouldShow = false;
    if (_promptCount == 0 && _roundCount >= 5) {
      shouldShow = true; // 第一次：5轮
    } else if (_promptCount == 1 && _roundCount >= 10) {
      shouldShow = true; // 第二次：10轮
    } else if (_promptCount == 2 && _roundCount >= 20) {
      shouldShow = true; // 第三次：20轮
    }
    
    if (!shouldShow) return;
    
    // 创建付费提示消息
    final promptMessage = _createPaymentPromptMessage();
    
    setState(() {
      _messages.add(promptMessage);
    });
    
    // 更新计数
    _savePromptCount(_promptCount + 1);
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 付费提示已触发（第${_promptCount + 1}次）'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // 创建付费提示消息
  ChatMessage _createPaymentPromptMessage() {
    final random = Random();
    final promptText = _paymentPromptMessages[random.nextInt(_paymentPromptMessages.length)];
    
    return ChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch, // 负数ID标识虚拟消息
      chatId: _mockChatId,
      senderId: 0, // 系统消息
      type: 'payment_prompt',
      context: jsonEncode({
        'type': 'payment_prompt',
        'source': 'test', // 标记为测试生成
        'content': promptText,
        'productId': '1',
        'variants': [
          {'id': 1, 'price': 30, 'name': '基础咨询'},
          {'id': 2, 'price': 50, 'name': '标准咨询', 'recommended': true},
          {'id': 3, 'price': 100, 'name': '深度咨询'},
        ],
      }),
      createTime: DateTime.now(),
      withdrawFlag: false,
      status: MessageStatus.read,
    );
  }
  
  // 清理测试数据
  Future<void> _resetTest() async {
    // 清除SharedPreferences中的计数
    await _savePromptCount(0);
    
    setState(() {
      _messages.clear();
      _roundCount = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 测试已重置'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  // 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // 构建消息列表
  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无消息',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '使用上方控制面板添加测试消息',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.senderId == 1; // 假设当前用户是买家
        
        if (message.type == 'payment_prompt') {
          // 付费提示使用专门的气泡
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: PaymentPromptBubble(
              message: message,
              onSelectVariant: (variantId) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('选择了套餐 ID: $variantId（测试模式，不会实际支付）'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          );
        }
        
        // 普通消息气泡
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.orange,
                  child: Text(
                    '卖',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.context ?? '',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '买',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bug_report, size: 20),
            const SizedBox(width: 8),
            const Text('付费提示测试'),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 测试控制面板
          _buildTestControlPanel(),
          
          // 消息列表
          Expanded(
            child: _buildMessageList(),
          ),
          
          // 底部说明
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '这是一个测试页面，用于验证付费提示功能',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}