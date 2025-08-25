import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lib/app/di/injection_container.dart';
import 'lib/features/chat/di/chat_di.dart';
import 'lib/features/chat/presentation/cubit/message_list/message_list_cubit.dart';
import 'lib/features/chat/domain/entities/chat_message.dart';
import 'lib/features/chat/presentation/widgets/payment_prompt_bubble.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  SharedPreferences.setMockInitialValues({});
  await InjectionContainer.init();
  await ChatDI.init(GetIt.instance);
  
  runApp(const TestPaymentPromptApp());
}

class TestPaymentPromptApp extends StatelessWidget {
  const TestPaymentPromptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Prompt Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestPaymentPromptPage(),
    );
  }
}

class TestPaymentPromptPage extends StatefulWidget {
  const TestPaymentPromptPage({super.key});

  @override
  State<TestPaymentPromptPage> createState() => _TestPaymentPromptPageState();
}

class _TestPaymentPromptPageState extends State<TestPaymentPromptPage> {
  late MessageListCubit _messageListCubit;
  int _messageCount = 0;
  
  @override
  void initState() {
    super.initState();
    _messageListCubit = GetIt.instance<MessageListCubit>();
    
    // 设置测试参数
    _messageListCubit.setCurrentUserParticipantId(1); // 卖家ID
    _messageListCubit.setSellerAndConsultationMode(
      isSeller: true,
      isLightConsultation: true,
    );
    
    // 加载测试消息
    _loadTestMessages();
  }
  
  void _loadTestMessages() {
    // 模拟已有的消息历史（4轮对话）
    final messages = [
      ChatMessage(
        id: 1,
        chatId: 100,
        senderId: 2, // 买家
        context: '你好，我想咨询一下这个产品',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 10)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 2,
        chatId: 100,
        senderId: 1, // 卖家
        context: '您好，欢迎咨询，请问有什么可以帮您？',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 9)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      // 添加更多消息以达到4轮
      ChatMessage(
        id: 3,
        chatId: 100,
        senderId: 2,
        context: '这个产品的质量如何？',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 8)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 4,
        chatId: 100,
        senderId: 1,
        context: '质量非常好，我们提供质保服务',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 7)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 5,
        chatId: 100,
        senderId: 2,
        context: '价格可以优惠吗？',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 6)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 6,
        chatId: 100,
        senderId: 1,
        context: '可以给您9折优惠',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 5)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 7,
        chatId: 100,
        senderId: 2,
        context: '那包邮吗？',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 4)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
      ChatMessage(
        id: 8,
        chatId: 100,
        senderId: 1,
        context: '满100元包邮',
        type: 'text',
        createTime: DateTime.now().subtract(const Duration(minutes: 3)),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
    ];
    
    setState(() {
      _messageCount = messages.length;
    });
  }
  
  void _simulateBuyerMessage() {
    // 模拟买家发送第5轮消息
    _messageListCubit.addReceivedMessage(
      ChatMessage(
        id: 100 + _messageCount,
        chatId: 100,
        senderId: 2, // 买家
        context: '还有其他颜色吗？',
        type: 'text',
        createTime: DateTime.now(),
        withdrawFlag: false,
        status: MessageStatus.sent,
      ),
    );
    
    setState(() {
      _messageCount++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Prompt Test'),
      ),
      body: BlocProvider.value(
        value: _messageListCubit,
        child: Column(
          children: [
            // 测试付费提示气泡组件
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '买家视角的付费提示：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    PaymentPromptBubble(
                      isSeller: false,
                      productId: '123',
                      variants: [
                        {'id': 1, 'price': 30, 'name': '基础咨询'},
                        {'id': 2, 'price': 50, 'name': '标准咨询'},
                        {'id': 3, 'price': 100, 'name': '深度咨询'},
                      ],
                      content: '根据平台规则，您已完成5轮免费咨询。继续咨询请选择服务套餐：',
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      '卖家视角的付费提示：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const PaymentPromptBubble(
                      isSeller: true,
                      productId: null,
                      variants: null,
                      content: '根据平台规则，您已完成5轮免费咨询。',
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        '当前消息数: $_messageCount',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 测试按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateBuyerMessage,
                      child: const Text('模拟买家发送第5轮消息'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _messageListCubit.close();
    super.dispose();
  }
}