import 'package:flutter/material.dart';

/// 产品详情页面
/// 
/// 显示产品的详细信息，包括图片、名称、价格、评分和描述
/// 在预览阶段使用mock数据，将来会替换为从API获取的真实数据
class ProductDetailPage extends StatelessWidget {
  /// 产品ID
  final String productId;
  
  const ProductDetailPage({required this.productId, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 使用mock数据
    // 注意：将来这里会替换为从API获取数据
    final mockProduct = _getMockProductDetail(productId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(mockProduct.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品图片
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                mockProduct.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 50),
                    ),
                  );
                },
              ),
            ),
            
            // 产品信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 产品名称
                  Text(
                    mockProduct.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  
                  // 价格
                  Row(
                    children: [
                      Text(
                        '¥${mockProduct.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 评分和评价数
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            mockProduct.score.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${mockProduct.evaluateNum}条评价)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 分割线
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // 产品描述标题
                  Text(
                    '服务描述',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 产品描述
                  Text(
                    mockProduct.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // 推荐按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 显示推荐确认对话框
                        _showRecommendDialog(context, mockProduct);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('让ta看看'),
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
  
  /// 显示推荐确认对话框
  void _showRecommendDialog(BuildContext context, _MockProductDetail product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推荐确认'),
        content: Text('确定要推荐"${product.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 显示推荐成功提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已推荐: ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 获取mock产品详情数据
  /// 注意：将来这里会替换为从API获取数据
  _MockProductDetail _getMockProductDetail(String productId) {
    // 根据产品ID生成不同的mock数据
    final id = int.tryParse(productId) ?? 0;
    
    return _MockProductDetail(
      id: productId,
      name: '模拟服务 $productId - ${_getServiceName(id)}',
      imageUrl: 'https://picsum.photos/800/450?random=$id',
      price: 100 + (id * 10),
      score: 4.0 + ((id % 10) / 10),
      evaluateNum: 10 + (id * 5),
      description: _getServiceDescription(id),
    );
  }
  
  /// 获取服务名称
  String _getServiceName(int id) {
    final serviceNames = [
      '文书润色服务',
      '留学申请指导',
      '作业辅导解答',
      '论文修改服务',
      '简历优化指导',
      '翻译服务',
      '数学题解答',
      '物理题解答',
      '化学题解答',
      '编程作业辅导',
    ];
    
    return serviceNames[id % serviceNames.length];
  }
  
  /// 获取服务描述
  String _getServiceDescription(int id) {
    final descriptions = [
      '我们的文书润色服务由经验丰富的专业编辑提供，他们将帮助您完善文章结构、语法和表达，使您的文书更加清晰、连贯和有说服力。',
      '我们的留学申请指导服务涵盖选校、文书写作、面试准备等全方位支持，帮助您提高申请成功率。',
      '我们的作业辅导解答服务由各学科专业人士提供，他们将帮助您理解难题、掌握解题方法，提高学习效率。',
      '我们的论文修改服务包括结构优化、内容完善、格式规范等方面，帮助您提高论文质量。',
      '我们的简历优化指导服务将帮助您突出个人优势、规范格式、提升专业形象，增加求职竞争力。',
      '我们的翻译服务覆盖多种语言，由专业译者提供，确保翻译准确、地道、专业。',
      '我们的数学题解答服务由数学专业人士提供，他们将帮助您理解数学概念、掌握解题技巧。',
      '我们的物理题解答服务由物理专业人士提供，他们将帮助您理解物理原理、掌握解题方法。',
      '我们的化学题解答服务由化学专业人士提供，他们将帮助您理解化学反应、掌握解题思路。',
      '我们的编程作业辅导由软件工程师提供，他们将帮助您理解编程概念、优化代码结构、解决技术难题。',
    ];
    
    return descriptions[id % descriptions.length];
  }
}

/// Mock产品详情数据模型
/// 注意：将来这会替换为真实的数据模型
class _MockProductDetail {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double score;
  final int evaluateNum;
  final String description;
  
  _MockProductDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.score,
    required this.evaluateNum,
    required this.description,
  });
}