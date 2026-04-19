import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context)?.seller_auth_status_title(_getAuthenticationTypeName(context, authInfo.type)) ?? '${_getAuthenticationTypeName(context, authInfo.type)} Certification'),
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
              Text(
                AppLocalizations.of(context)?.seller_auth_status_label ?? 'Status: ',
                style: const TextStyle(
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
              Text(
                AppLocalizations.of(context)?.seller_auth_status_name_label ?? 'Name: ',
                style: const TextStyle(
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
          AppLocalizations.of(context)?.seller_auth_status_materials ?? 'Certification Materials',
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
            child: Center(
              child: Text(
                AppLocalizations.of(context)?.seller_auth_status_no_materials ?? 'No certification materials',
                style: const TextStyle(color: Colors.grey),
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
    final Map<String, String> fields = _getAuthFields(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.seller_auth_status_info ?? 'Certification Info',
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
    final List<Map<String, String>> history = _getAuthHistory(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.seller_auth_status_history ?? 'Certification History',
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(AppLocalizations.of(context)?.seller_auth_status_no_history ?? 'No history records'),
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
              child: Text(AppLocalizations.of(context)?.seller_auth_status_reapply ?? 'Reapply', style: const TextStyle(fontSize: 16)),
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
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.seller_auth_status_approved_hint ?? 'Certification approved, no need to resubmit',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
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
            child: Row(
              children: [
                const Icon(Icons.hourglass_top, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.seller_auth_status_pending_hint ?? 'Certification under review, please wait',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
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
    final l10n = AppLocalizations.of(context);
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case AuthenticationStatus.approved:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        text = l10n?.seller_auth_status_tag_approved ?? 'Certified';
        icon = Icons.check_circle;
        break;
      case AuthenticationStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        text = l10n?.seller_auth_status_tag_pending ?? 'Under Review';
        icon = Icons.hourglass_top;
        break;
      case AuthenticationStatus.rejected:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        text = l10n?.seller_auth_status_tag_rejected ?? 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
        text = l10n?.seller_auth_status_tag_not_submitted ?? 'Not Submitted';
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
  String _getAuthenticationTypeName(BuildContext context, AuthenticationType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case AuthenticationType.idCard:
        return l10n?.seller_auth_status_type_idcard ?? 'Identity';
      case AuthenticationType.education:
        return l10n?.seller_auth_status_type_education ?? 'Education';
      case AuthenticationType.profession:
        return l10n?.seller_auth_status_type_profession ?? 'Profession';
      case AuthenticationType.company:
        return l10n?.seller_auth_status_type_company ?? 'Company';
      default:
        return l10n?.seller_auth_status_type_other ?? 'Other';
    }
  }
  
  /// 获取认证字段
  Map<String, String> _getAuthFields(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Map<String, String> fields = {};

    // 基本信息
    fields[l10n?.seller_auth_status_field_auth_name ?? 'Certification Name'] = authInfo.name;
    fields[l10n?.seller_auth_status_field_auth_type ?? 'Certification Type'] = authInfo.type.displayName;

    // 从实际数据中获取字段
    if (authInfo.fields != null) {
      final authFields = authInfo.fields!;

      // 获取提交的姓名/公司名称
      if (authFields.containsKey('name')) {
        switch (authInfo.type) {
          case AuthenticationType.company:
            fields[l10n?.seller_auth_status_field_company_name ?? 'Company Name'] = authFields['name'].toString();
            break;
          case AuthenticationType.idCard:
            fields[l10n?.seller_auth_status_field_name ?? 'Name'] = authFields['name'].toString();
            break;
          case AuthenticationType.education:
            fields[l10n?.seller_auth_status_field_school_name ?? 'School Name'] = authFields['name'].toString();
            break;
          case AuthenticationType.profession:
            fields[l10n?.seller_auth_status_field_profession ?? 'Profession/Position'] = authFields['name'].toString();
            break;
          default:
            fields[l10n?.seller_auth_status_field_name_or_title ?? 'Name/Title'] = authFields['name'].toString();
        }
      }

      // 获取备注信息
      if (authFields.containsKey('remarks') && authFields['remarks'].toString().isNotEmpty) {
        fields[l10n?.seller_auth_status_field_remarks ?? 'Remarks'] = authFields['remarks'].toString();
      }

      // 根据认证类型显示特定字段
      if (authFields.containsKey('feature') && authFields['feature'] is Map<String, dynamic>) {
        final feature = authFields['feature'] as Map<String, dynamic>;

        switch (authInfo.type) {
          case AuthenticationType.profession:
            if (feature.containsKey('certificateNumber')) {
              fields[l10n?.seller_auth_status_field_cert_number ?? 'Certificate Number'] = feature['certificateNumber'].toString();
            }
            if (feature.containsKey('workExperience')) {
              fields[l10n?.seller_auth_status_field_work_experience ?? 'Work Experience'] = feature['workExperience'].toString();
            }
            if (feature.containsKey('issuer')) {
              fields[l10n?.seller_auth_status_field_issuer ?? 'Issuing Authority'] = feature['issuer'].toString();
            }
            break;

          case AuthenticationType.company:
            if (feature.containsKey('creditCode')) {
              fields[l10n?.seller_auth_status_field_credit_code ?? 'Unified Social Credit Code'] = feature['creditCode'].toString();
            }
            if (feature.containsKey('legalRepresentative')) {
              fields[l10n?.seller_auth_status_field_legal_rep ?? 'Legal Representative'] = feature['legalRepresentative'].toString();
            }
            if (feature.containsKey('registeredCapital')) {
              fields[l10n?.seller_auth_status_field_registered_capital ?? 'Registered Capital'] = feature['registeredCapital'].toString();
            }
            if (feature.containsKey('establishmentDate')) {
              fields[l10n?.seller_auth_status_field_establishment_date ?? 'Establishment Date'] = feature['establishmentDate'].toString();
            }
            break;

          case AuthenticationType.education:
            if (feature.containsKey('degree')) {
              fields[l10n?.seller_auth_status_field_degree ?? 'Degree'] = feature['degree'].toString();
            }
            if (feature.containsKey('major')) {
              fields[l10n?.seller_auth_status_field_major ?? 'Major'] = feature['major'].toString();
            }
            if (feature.containsKey('graduationYear')) {
              fields[l10n?.seller_auth_status_field_graduation_year ?? 'Graduation Year'] = feature['graduationYear'].toString();
            }
            break;

          case AuthenticationType.idCard:
            if (feature.containsKey('idNumber')) {
              // 身份证号部分隐藏
              final idNumber = feature['idNumber'].toString();
              if (idNumber.length > 10) {
                fields[l10n?.seller_auth_status_field_id_number ?? 'ID Number'] = '${idNumber.substring(0, 6)}****${idNumber.substring(idNumber.length - 4)}';
              } else {
                fields[l10n?.seller_auth_status_field_id_number ?? 'ID Number'] = idNumber;
              }
            }
            if (feature.containsKey('validPeriod')) {
              fields[l10n?.seller_auth_status_field_valid_period ?? 'Valid Period'] = feature['validPeriod'].toString();
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
      fields[l10n?.seller_auth_status_field_submit_time ?? 'Submission Time'] = _formatDateTime(authInfo.submittedAt!);
    }

    // 如果是被拒绝的认证，显示拒绝原因
    if (authInfo.status == AuthenticationStatus.rejected &&
        authInfo.rejectionReason != null &&
        authInfo.rejectionReason!.isNotEmpty) {
      fields[l10n?.seller_auth_status_field_reject_reason ?? 'Rejection Reason'] = authInfo.rejectionReason!;
    }

    return fields;
  }
  
  /// 获取认证历史
  List<Map<String, String>> _getAuthHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 这里应该根据实际数据构建历史记录
    // 示例数据
    final List<Map<String, String>> history = [];
    final typeName = authInfo.type.displayName;

    // 认证状态相关历史
    switch (authInfo.status) {
      case AuthenticationStatus.approved:
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 3))),
          'title': l10n?.seller_auth_status_history_approved_title ?? 'Certification Approved',
          'description': l10n?.seller_auth_status_history_approved_desc(typeName) ?? 'Your $typeName certification has been approved.',
        });
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 5))),
          'title': l10n?.seller_auth_status_history_submitted_title ?? 'Certification Submitted',
          'description': l10n?.seller_auth_status_history_submitted_desc(typeName) ?? 'Your $typeName certification has been submitted.',
        });
        break;

      case AuthenticationStatus.pending:
        history.add({
          'time': _formatDateTime(authInfo.submittedAt ?? DateTime.now().subtract(const Duration(days: 1))),
          'title': l10n?.seller_auth_status_history_submitted_title ?? 'Certification Submitted',
          'description': l10n?.seller_auth_status_history_submitted_desc(typeName) ?? 'Your $typeName certification has been submitted.',
        });
        break;

      case AuthenticationStatus.rejected:
        final reason = authInfo.rejectionReason ?? (l10n?.seller_auth_status_history_rejected_default_reason ?? 'Materials do not meet requirements');
        history.add({
          'time': _formatDateTime(DateTime.now().subtract(const Duration(days: 2))),
          'title': l10n?.seller_auth_status_history_rejected_title ?? 'Certification Rejected',
          'description': l10n?.seller_auth_status_history_rejected_desc(typeName, reason) ?? 'Your $typeName certification was rejected. Reason: $reason',
        });
        history.add({
          'time': _formatDateTime(authInfo.submittedAt ?? DateTime.now().subtract(const Duration(days: 5))),
          'title': l10n?.seller_auth_status_history_submitted_title ?? 'Certification Submitted',
          'description': l10n?.seller_auth_status_history_submitted_desc(typeName) ?? 'Your $typeName certification has been submitted.',
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