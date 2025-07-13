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
    final images = _getAuthImages();
    
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
        // 如果没有图片，显示提示
        if (images.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                '暂无认证材料',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
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
        // 只有在被拒绝时才显示重新认证按钮
        if (authInfo.status == AuthenticationStatus.rejected) ...[
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
        ] else if (authInfo.status == AuthenticationStatus.approved) ...[
          // 已认证通过，显示状态提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '认证已通过，无需重复提交',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ] else if (authInfo.status == AuthenticationStatus.pending) ...[
          // 审核中，显示等待提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '认证审核中，请耐心等待',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ]
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
      'sellerAuthenticationApply',
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
    final Map<String, String> fields = {};
    
    // 基本信息
    fields['认证名称'] = authInfo.name;
    fields['认证类型'] = authInfo.type.displayName;
    
    // 从实际数据中获取字段
    if (authInfo.fields != null) {
      final authFields = authInfo.fields!;
      
      // 获取提交的姓名/公司名称
      if (authFields.containsKey('name')) {
        switch (authInfo.type) {
          case AuthenticationType.company:
            fields['公司名称'] = authFields['name'].toString();
            break;
          case AuthenticationType.idCard:
            fields['姓名'] = authFields['name'].toString();
            break;
          case AuthenticationType.education:
            fields['学校名称'] = authFields['name'].toString();
            break;
          case AuthenticationType.profession:
            fields['职业/职位'] = authFields['name'].toString();
            break;
          default:
            fields['姓名/名称'] = authFields['name'].toString();
        }
      }
      
      // 获取备注信息
      if (authFields.containsKey('remarks') && authFields['remarks'].toString().isNotEmpty) {
        fields['备注'] = authFields['remarks'].toString();
      }
      
      // 根据认证类型显示特定字段
      if (authFields.containsKey('feature') && authFields['feature'] is Map<String, dynamic>) {
        final feature = authFields['feature'] as Map<String, dynamic>;
        
        switch (authInfo.type) {
          case AuthenticationType.profession:
            if (feature.containsKey('certificateNumber')) {
              fields['证书编号'] = feature['certificateNumber'].toString();
            }
            if (feature.containsKey('workExperience')) {
              fields['工作经验'] = feature['workExperience'].toString();
            }
            if (feature.containsKey('issuer')) {
              fields['发证机构'] = feature['issuer'].toString();
            }
            break;
            
          case AuthenticationType.company:
            if (feature.containsKey('creditCode')) {
              fields['统一社会信用代码'] = feature['creditCode'].toString();
            }
            if (feature.containsKey('legalRepresentative')) {
              fields['法人代表'] = feature['legalRepresentative'].toString();
            }
            if (feature.containsKey('registeredCapital')) {
              fields['注册资本'] = feature['registeredCapital'].toString();
            }
            if (feature.containsKey('establishmentDate')) {
              fields['成立日期'] = feature['establishmentDate'].toString();
            }
            break;
            
          case AuthenticationType.education:
            if (feature.containsKey('degree')) {
              fields['学历'] = feature['degree'].toString();
            }
            if (feature.containsKey('major')) {
              fields['专业'] = feature['major'].toString();
            }
            if (feature.containsKey('graduationYear')) {
              fields['毕业年份'] = feature['graduationYear'].toString();
            }
            break;
            
          case AuthenticationType.idCard:
            if (feature.containsKey('idNumber')) {
              // 身份证号部分隐藏
              final idNumber = feature['idNumber'].toString();
              if (idNumber.length > 10) {
                fields['身份证号'] = '${idNumber.substring(0, 6)}****${idNumber.substring(idNumber.length - 4)}';
              } else {
                fields['身份证号'] = idNumber;
              }
            }
            if (feature.containsKey('validPeriod')) {
              fields['有效期'] = feature['validPeriod'].toString();
            }
            break;
            
          default:
            // 对于其他类型，显示所有feature字段
            feature.forEach((key, value) {
              if (value != null && value.toString().isNotEmpty) {
                fields[key] = value.toString();
              }
            });
        }
      }
    }
    
    // 添加时间信息
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
    // 修复：添加调试信息并增强图片获取逻辑
    print('获取认证图片 - 认证名称: ${authInfo.name}');
    print('认证字段数据: ${authInfo.fields}');
    
    // 修复：从实际认证数据中获取图片
    if (authInfo.fields != null && authInfo.fields!.containsKey('images')) {
      final images = authInfo.fields!['images'];
      print('找到图片数据: $images (类型: ${images.runtimeType})');
      
      if (images is List) {
        final imageUrls = images.map((img) => img.toString()).where((url) => url.isNotEmpty).toList();
        print('解析图片列表: $imageUrls');
        return imageUrls;
      } else if (images is String && images.isNotEmpty) {
        final imageUrls = images.split(',').where((img) => img.trim().isNotEmpty).map((img) => img.trim()).toList();
        print('解析图片字符串: $imageUrls');
        return imageUrls;
      }
    }
    
    // 修复：如果上面没有找到，尝试从其他可能的字段获取
    if (authInfo.fields != null) {
      // 尝试从根级别的其他可能字段获取图片
      for (final key in ['imageUrls', 'attachments', 'documents', 'files']) {
        if (authInfo.fields!.containsKey(key)) {
          final value = authInfo.fields![key];
          print('尝试从 $key 字段获取图片: $value');
          
          if (value is List && value.isNotEmpty) {
            final imageUrls = value.map((img) => img.toString()).where((url) => url.isNotEmpty).toList();
            if (imageUrls.isNotEmpty) {
              print('从 $key 字段找到图片: $imageUrls');
              return imageUrls;
            }
          } else if (value is String && value.isNotEmpty) {
            final imageUrls = value.split(',').where((img) => img.trim().isNotEmpty).map((img) => img.trim()).toList();
            if (imageUrls.isNotEmpty) {
              print('从 $key 字段解析图片: $imageUrls');
              return imageUrls;
            }
          }
        }
      }
    }
    
    print('没有找到图片数据');
    return [];
  }
  
  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 