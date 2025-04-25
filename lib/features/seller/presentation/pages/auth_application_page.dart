import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_application/auth_application_bloc.dart';
import 'package:file_picker/file_picker.dart';

/// 认证申请页面
class AuthApplicationPage extends StatefulWidget {
  /// 认证类型
  final String type;
  
  /// 认证信息（如果是已经有的认证）
  final SellerAuthenticationInfo? authInfo;
  
  /// 构造函数
  const AuthApplicationPage({
    Key? key,
    required this.type,
    this.authInfo,
  }) : super(key: key);

  @override
  State<AuthApplicationPage> createState() => _AuthApplicationPageState();
}

class _AuthApplicationPageState extends State<AuthApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  late AuthenticationType _authenticationType;
  final List<String> _selectedFiles = [];
  
  // 表单字段
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // 错误信息
  final Map<String, String> _fieldErrors = {};
  
  @override
  void initState() {
    super.initState();
    // 根据路由参数确定认证类型
    _authenticationType = _getAuthenticationTypeFromString(widget.type);
    
    // 如果有已存在的认证信息，填充表单
    if (widget.authInfo != null) {
      _nameController.text = widget.authInfo!.name;
      // 如果有其他字段需要填充，这里添加
      final fields = widget.authInfo!.fields;
      if (fields != null && fields.containsKey('id')) {
        _identifierController.text = fields['id'];
      }
      
      if (widget.authInfo!.remarks != null) {
        _descriptionController.text = widget.authInfo!.remarks!;
      }
    }
    
    // 初始化Bloc
    Future.microtask(() {
      context.read<AuthApplicationBloc>().add(
        InitializeAuthApplicationForm(
          authenticationType: _authenticationType,
          authInfo: widget.authInfo,
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthApplicationBloc, AuthApplicationState>(
      listener: (context, state) {
        if (state is AuthApplicationValidationError) {
          setState(() {
            _fieldErrors.clear();
            _fieldErrors.addAll(state.fieldErrors);
          });
          _showErrorSnackBar('请检查表单填写是否正确');
        } else if (state is AuthApplicationFailure) {
          _showErrorSnackBar(state.message);
        } else if (state is AuthApplicationSuccess) {
          _showSuccessDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_getAuthenticationTypeName(_authenticationType)}认证'),
        ),
        body: BlocBuilder<AuthApplicationBloc, AuthApplicationState>(
          builder: (context, state) {
            final isSubmitting = state is AuthApplicationSubmitting;
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 认证说明
                    _buildIntroSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 认证表单
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 根据认证类型动态构建表单字段
                          ..._buildFormFields(),
                          
                          const SizedBox(height: 24),
                          
                          // 上传证明材料
                          Text(
                            '上传证明材料',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFileUploadSection(),
                          if (_fieldErrors.containsKey('files'))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _fieldErrors['files']!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // 同意条款
                          _buildAgreementSection(),
                          
                          const SizedBox(height: 32),
                          
                          // 提交按钮
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: isSubmitting 
                                ? const CircularProgressIndicator() 
                                : const Text('提交认证申请', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// 构建认证介绍部分
  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getAuthenticationTypeName(_authenticationType)}认证说明',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getAuthenticationTypeDescription(_authenticationType),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '认证审核通常需要1-3个工作日，请耐心等待。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建表单字段
  List<Widget> _buildFormFields() {
    final List<Widget> fields = [];
    
    // 所有认证类型都需要的通用字段
    fields.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            '基本信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
    
    // 根据认证类型添加特定字段
    switch (_authenticationType) {
      case AuthenticationType.company:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '公司名称',
              hintText: '请输入公司全称',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入公司名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: '统一社会信用代码',
              hintText: '请输入18位统一社会信用代码',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入统一社会信用代码';
              }
              if (value.length != 18) {
                return '统一社会信用代码应为18位';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '企业简介',
              hintText: '请简要描述公司业务和情况',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]);
        break;
        
      case AuthenticationType.idCard:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '姓名',
              hintText: '请输入您的真实姓名',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入姓名';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: '身份证号码',
              hintText: '请输入18位身份证号码',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入身份证号码';
              }
              if (value.length != 18) {
                return '身份证号码应为18位';
              }
              return null;
            },
          ),
        ]);
        break;
        
      case AuthenticationType.education:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '学校名称',
              hintText: '请输入学校全称',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入学校名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: '学历/学位',
              hintText: '如：本科、硕士等',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入学历/学位';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '专业',
              hintText: '请输入专业名称',
              border: OutlineInputBorder(),
            ),
          ),
        ]);
        break;
        
      case AuthenticationType.profession:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '职业/职位',
              hintText: '请输入您的职业或职位',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入职业/职位';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: '证书编号',
              hintText: '请输入职业资格证书编号',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '工作经验',
              hintText: '请简要描述您的工作经验',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]);
        break;
        
      default:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '认证名称',
              hintText: '请输入认证名称',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入认证名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: '认证标识',
              hintText: '请输入认证标识或编号',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '认证描述',
              hintText: '请描述认证内容',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]);
    }
    
    return fields;
  }
  
  /// 构建文件上传区域
  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildUploadButton(),
            const SizedBox(width: 16),
            if (_selectedFiles.isNotEmpty) ...[
              Text('已选择 ${_selectedFiles.length} 个文件', style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getUploadHint(_authenticationType),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
  
  /// 构建上传按钮
  Widget _buildUploadButton() {
    return InkWell(
      onTap: _selectFiles,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 36, color: Colors.grey),
            SizedBox(height: 8),
            Text('上传文件', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  /// 构建协议同意部分
  Widget _buildAgreementSection() {
    return Row(
      children: [
        Checkbox(
          value: true, // 实际项目中应使用状态变量
          onChanged: (value) {
            // 处理协议同意状态变更
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                const TextSpan(text: '我已阅读并同意'),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _showAgreement,
                    child: Text(
                      '《认证服务协议》',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '，保证所提供的信息真实有效'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 显示服务协议
  void _showAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('认证服务协议'),
        content: const SingleChildScrollView(
          child: Text(
            '本协议是您与DSKK平台之间关于认证服务的法律协议。请您仔细阅读以下条款，确保完全理解本协议中的所有权利和义务。'
            '\n\n一、服务内容\nDSKK平台提供认证服务，旨在验证您提供的身份、资质等信息的真实性，提高您在平台上的可信度。'
            '\n\n二、用户义务\n1. 您应当提供真实、准确、完整的认证信息和材料。\n2. 您应当确保提供的认证材料不侵犯任何第三方的合法权益。'
            '\n\n三、平台权利与义务\n1. 平台有权对您提供的认证信息和材料进行审核。\n2. 平台将在合理的时间内完成审核，并告知您审核结果。'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('同意'),
          ),
        ],
      ),
    );
  }
  
  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  /// 显示成功对话框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('提交成功'),
        content: const Text('您的认证申请已提交，我们将在1-3个工作日内完成审核，请耐心等待。'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 返回上一页
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 选择文件
  void _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            result.files
              .where((file) => file.path != null)
              .map((file) => file.path!)
              .toList()
          );
          // 清除相关错误
          _fieldErrors.remove('files');
        });
      }
    } catch (e) {
      _showErrorSnackBar('选择文件失败: $e');
    }
  }
  
  /// 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 提交表单数据到Bloc
      context.read<AuthApplicationBloc>().add(
        SubmitAuthApplication(
          authenticationType: _authenticationType,
          name: _nameController.text.trim(),
          identifier: _identifierController.text.trim(),
          description: _descriptionController.text.trim(),
          filePaths: _selectedFiles,
          authInfo: widget.authInfo,
        ),
      );
    }
  }
  
  /// 根据字符串获取认证类型
  AuthenticationType _getAuthenticationTypeFromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'id_card':
      case 'idcard':
        return AuthenticationType.idCard;
      case 'education':
        return AuthenticationType.education;
      case 'profession':
        return AuthenticationType.profession;
      case 'company':
        return AuthenticationType.company;
      default:
        return AuthenticationType.other;
    }
  }
  
  /// 获取认证类型显示名称
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
  
  /// 获取认证类型描述
  String _getAuthenticationTypeDescription(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return '身份认证可以增加您的账号可信度，保护您的账号安全。请上传您的身份证正反面照片。';
      case AuthenticationType.education:
        return '学历认证可以增加您的专业可信度，提升您的订单接单率。请上传您的学历证书照片。';
      case AuthenticationType.profession:
        return '职业认证可以展示您的专业能力，提高您的服务可信度。请上传您的职业资格证书照片。';
      case AuthenticationType.company:
        return '公司认证可以增加您的企业形象，提升您的品牌价值。请上传营业执照等相关证明材料。';
      default:
        return '认证可以增加您的账号可信度，提高您的服务质量评分。请上传相关证明材料。';
    }
  }
  
  /// 获取上传提示文字
  String _getUploadHint(AuthenticationType type) {
    switch (type) {
      case AuthenticationType.idCard:
        return '请上传清晰的身份证正反面照片，确保信息清晰可见，不得遮挡、涂改';
      case AuthenticationType.education:
        return '请上传学历证书、学位证书等证明材料，需包含完整信息';
      case AuthenticationType.profession:
        return '请上传职业资格证书、专业技能证书等证明材料';
      case AuthenticationType.company:
        return '请上传营业执照、组织机构代码证等企业资质证明材料';
      default:
        return '请上传相关证明材料，确保图片清晰、信息完整';
    }
  }
} 