import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';

/// 认证状态详情页面
class AuthStatusPage extends StatelessWidget {
  /// 认证信息
  final SellerAuthenticationInfo authInfo;
  
  /// 构造函数
  const AuthStatusPage({
    Key? key,
    required this.authInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getAuthenticationTypeName(authInfo.type)}认证'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 认证状态
              _buildStatusSection(context),
              
              const SizedBox(height: 24),
              
              // 认证材料
              _buildMaterialsSection(context),
              
              const SizedBox(height: 24),
              
              // 认证信息
              _buildInfoSection(context),
              
              const SizedBox(height: 24),
              
              // 认证历史
              _buildHistorySection(context),
              
              const SizedBox(height: 32),
              
              // 底部按钮
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建状态部分
  Widget _buildStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '认证状态：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusTag(authInfo.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '认证名称：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  authInfo.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建认证材料部分
  Widget _buildMaterialsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '认证材料',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _getAuthImages().length,
            itemBuilder: (context, index) {
              final imageUrl = _getAuthImages()[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, imageUrl),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// 构建认证信息部分
  Widget _buildInfoSection(BuildContext context) {
    final Map<String, String> fields = _getAuthFields();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '认证信息',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: fields.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}：',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  /// 构建认证历史部分
  Widget _buildHistorySection(BuildContext context) {
    final List<Map<String, String>> history = _getAuthHistory();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '认证历史',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: history.isEmpty 
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('暂无历史记录'),
                  ),
                )
              : Column(
                  children: history.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(top: 2, right: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['time'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item['description'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
  
  /// 构建底部按钮
  Widget _buildBottomButtons(BuildContext context) {
    return Column(
      children: [
        if (authInfo.status == AuthenticationStatus.rejected || 
            authInfo.status == AuthenticationStatus.approved) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _reapplyAuth(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('重新认证', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }
  
  /// 构建状态标签
  Widget _buildStatusTag(AuthenticationStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case AuthenticationStatus.approved:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        text = '已认证';
        icon = Icons.check_circle;
        break;
      case AuthenticationStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        text = '审核中';
        icon = Icons.hourglass_top;
        break;
      case AuthenticationStatus.rejected:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        text = '未通过';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
        text = '未提交';
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 全屏查看图片
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Stack(
          children: [
            Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 80,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 重新申请认证
  void _reapplyAuth(BuildContext context) {
    context.pushNamed(
      'seller_authentication_apply',
      pathParameters: {'type': authInfo.type.value.toLowerCase()},
      extra: authInfo,
    );
  }
  
  /// 获取认证类型名称
  String _getAuthenticationTypeName(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return '身份';
      case AuthenticationType.education:
        return '学历';
      case AuthenticationType.profession:
        return '职业';
      case AuthenticationType.company:
        return '公司';
      default:
        return '其他';
    }
  }
  
  /// 获取认证字段
  Map<String, String> _getAuthFields() {
    // 这里根据认证类型和字段构建显示的信息
    // 实际项目中应从 authInfo.fields 中获取
    
    final Map<String, String> fields = {};
    
    switch (authInfo.type) {
      case AuthenticationType.company:
        fields['公司名称'] = authInfo.name;
        fields['统一社会信用代码'] = '91110105MA00B7F30G'; // 示例数据
        fields['法人代表'] = '张三'; // 示例数据
        fields['注册资本'] = '1000万元'; // 示例数据
        fields['成立日期'] = '2020年01月01日'; // 示例数据
        break;
        
      case AuthenticationType.idCard:
        fields['姓名'] = authInfo.name;
        fields['身份证号'] = '110101199001011234'; // 示例数据，实际应用中应部分隐藏
        fields['有效期'] = '2020.01.01-2030.01.01'; // 示例数据
        break;
        
      case AuthenticationType.education:
        fields['学校名称'] = authInfo.name;
        fields['学历'] = '本科'; // 示例数据
        fields['专业'] = '计算机科学与技术'; // 示例数据
        fields['毕业年份'] = '2020年'; // 示例数据
        break;
        
      case AuthenticationType.profession:
        fields['职业'] = authInfo.name;
        fields['证书编号'] = 'PROF12345678'; // 示例数据
        fields['发证机构'] = '中国XXX协会'; // 示例数据
        fields['发证日期'] = '2019年06月01日'; // 示例数据
        break;
        
      default:
        fields['认证名称'] = authInfo.name;
        fields['认证类型'] = authInfo.type.displayName;
    }
    
    // 添加认证时间
    if (authInfo.submittedAt != null) {
      fields['提交时间'] = _formatDateTime(authInfo.submittedAt!);
    }
    
    // 如果是被拒绝的认证，显示拒绝原因
    if (authInfo.status == AuthenticationStatus.rejected && 
        authInfo.rejectionReason != null && 
        authInfo.rejectionReason!.isNotEmpty) {
      fields['拒绝原因'] = authInfo.rejectionReason!;
    }
    
    return fields;
  }
  
  /// 获取认证历史
  List<Map<String, String>> _getAuthHistory() {
    // 这里应该根据实际数据构建历史记录
    // 示例数据
    final List<Map<String, String>> history = [];
    
    // 认证状态相关历史
    switch (authInfo.status) {
      case AuthenticationStatus.approved:
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 3))),
          'title': '认证申请通过',
          'description': '您的${authInfo.type.displayName}认证申请已通过审核，现在您可以享受认证商家的所有权益。',
        });
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 5))),
          'title': '提交认证申请',
          'description': '您已成功提交${authInfo.type.displayName}认证申请，我们将在1-3个工作日内完成审核。',
        });
        break;
        
      case AuthenticationStatus.pending:
        history.add({
          'time': _formatDateTime(authInfo.submittedAt ?? DateTime.now().subtract(const Duration(days: 1))),
          'title': '提交认证申请',
          'description': '您已成功提交${authInfo.type.displayName}认证申请，我们将在1-3个工作日内完成审核。',
        });
        break;
        
      case AuthenticationStatus.rejected:
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 2))),
          'title': '认证申请未通过',
          'description': '您的${authInfo.type.displayName}认证申请未通过审核。原因：${authInfo.rejectionReason ?? "资料不符合要求"}',
        });
        history.add({
          'time': _formatDateTime(authInfo.submittedAt ?? DateTime.now().subtract(const Duration(days: 5))),
          'title': '提交认证申请',
          'description': '您已成功提交${authInfo.type.displayName}认证申请，我们将在1-3个工作日内完成审核。',
        });
        break;
        
      default:
        // 未提交状态不显示历史
        break;
    }
    
    return history;
  }
  
  /// 获取认证相关图片
  List<String> _getAuthImages() {
    // 实际项目中应从 authInfo.fields 或其他字段中获取
    // 这里使用示例图片
    return [
      'https://images.unsplash.com/photo-1611503568137-dce2d95e825c?ixlib=rb-4.0.3&q=85&w=320',
      'https://images.unsplash.com/photo-1611503568137-dce2d95e825c?ixlib=rb-4.0.3&q=85&w=320',
    ];
  }
  
  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 