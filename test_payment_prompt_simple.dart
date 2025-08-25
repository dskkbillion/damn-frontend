import 'package:flutter/material.dart';
import 'lib/features/chat/presentation/widgets/payment_prompt_bubble.dart';

void main() {
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

class TestPaymentPromptPage extends StatelessWidget {
  const TestPaymentPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('付费提示测试'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '买家视角的付费提示：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),
            const Text(
              '卖家视角的付费提示：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const PaymentPromptBubble(
              isSeller: true,
              productId: null,
              variants: null,
              content: '根据平台规则，您已完成5轮免费咨询。',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),
            const Text(
              '无商品价格信息时的买家视角：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const PaymentPromptBubble(
              isSeller: false,
              productId: null,
              variants: null,
              content: '根据平台规则，您已完成5轮免费咨询。继续咨询请联系卖家了解付费方案。',
            ),
          ],
        ),
      ),
    );
  }
}