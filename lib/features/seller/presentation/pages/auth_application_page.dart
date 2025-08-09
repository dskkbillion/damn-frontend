import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_application/auth_application_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
          final l10n = AppLocalizations.of(context);
          _showErrorSnackBar(l10n?.seller_auth_application_check_form ?? 'Please check the form');
        } else if (state is AuthApplicationFailure) {
          _showErrorSnackBar(state.message);
        } else if (state is AuthApplicationSuccess) {
          _showSuccessDialog();
        }
      },
      child: Builder(
        builder: (innerContext) {
          final l10n = AppLocalizations.of(innerContext);
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n?.seller_auth_application_title?.call(
                _getAuthenticationTypeName(_authenticationType)
              ) ?? 'Authentication Application'),
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
                            AppLocalizations.of(innerContext)?.seller_auth_application_upload_materials ?? 'Upload Materials',
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
                                : Text(AppLocalizations.of(innerContext)?.seller_auth_application_submit ?? 'Submit', style: const TextStyle(fontSize: 16)),
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
      );
      },
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
            (AppLocalizations.of(context)?.seller_auth_application_desc?.call(
              _getAuthenticationTypeName(_authenticationType)
            ) ?? 'Please prepare the following materials'),
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
          Text(
            AppLocalizations.of(context)?.seller_auth_application_review_time ?? 'Review time: 1-3 business days',
            style: const TextStyle(
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
            AppLocalizations.of(context)?.seller_auth_application_basic_info ?? 'Basic Information',
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
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_company_name ?? 'Company Name',
              hintText: _l10n?.seller_auth_application_company_name_hint ?? 'Enter company name',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_company_name_required ?? 'Company name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_credit_code ?? 'Unified Social Credit Code',
              hintText: _l10n?.seller_auth_application_credit_code_hint ?? 'Enter 18-digit credit code',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_credit_code_required ?? 'Credit code is required';
              }
              if (value.length != 18) {
                return _l10n?.seller_auth_application_credit_code_invalid ?? 'Credit code must be 18 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_company_intro ?? 'Company Introduction',
              hintText: _l10n?.seller_auth_application_company_intro_hint ?? 'Brief introduction of your company',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]);
        break;
        
      case AuthenticationType.idCard:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_real_name ?? 'Real Name',
              hintText: _l10n?.seller_auth_application_real_name_hint ?? 'Enter your real name',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_real_name_required ?? 'Real name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_id_number ?? 'ID Number',
              hintText: _l10n?.seller_auth_application_id_number_hint ?? 'Enter 18-digit ID number',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_id_number_required ?? 'ID number is required';
              }
              if (value.length != 18) {
                return _l10n?.seller_auth_application_id_number_invalid ?? 'ID number must be 18 digits';
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
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_school_name ?? 'School Name',
              hintText: _l10n?.seller_auth_application_school_name_hint ?? 'Enter your school name',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_school_name_required ?? 'School name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_degree ?? 'Degree',
              hintText: _l10n?.seller_auth_application_degree_hint ?? 'e.g., Bachelor, Master, PhD',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_degree_required ?? 'Degree is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_major ?? 'Major',
              hintText: _l10n?.seller_auth_application_major_hint ?? 'Enter your major',
              border: const OutlineInputBorder(),
            ),
          ),
        ]);
        break;
        
      case AuthenticationType.profession:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_profession ?? 'Profession',
              hintText: _l10n?.seller_auth_application_profession_hint ?? 'Enter your profession',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_profession_required ?? 'Profession is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_cert_number ?? 'Certificate Number',
              hintText: _l10n?.seller_auth_application_cert_number_hint ?? 'Enter certificate number',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_work_experience ?? 'Work Experience',
              hintText: _l10n?.seller_auth_application_work_experience_hint ?? 'Describe your work experience',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ]);
        break;
        
      default:
        fields.addAll([
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_auth_name ?? 'Authentication Name',
              hintText: _l10n?.seller_auth_application_auth_name_hint ?? 'Enter authentication name',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _l10n?.seller_auth_application_auth_name_required ?? 'Authentication name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_auth_identifier ?? 'Identifier',
              hintText: _l10n?.seller_auth_application_auth_identifier_hint ?? 'Enter identifier',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: _l10n?.seller_auth_application_auth_description ?? 'Description',
              hintText: _l10n?.seller_auth_application_auth_description_hint ?? 'Enter description',
              border: const OutlineInputBorder(),
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
        // 上传按钮和提示文字
        Row(
          children: [
            _buildUploadButton(),
            const SizedBox(width: 16),
            if (_selectedFiles.isNotEmpty) ...[
              Text(_l10n?.seller_auth_application_selected_files?.call(_selectedFiles.length) ?? '${_selectedFiles.length} files selected', style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getUploadHint(_authenticationType),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        
        // 添加已选择图片的显示
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            _l10n?.seller_auth_application_selected_images ?? 'Selected Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final filePath = _selectedFiles[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // 显示图片
                      Image.file(
                        File(filePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _l10n?.seller_auth_application_load_failed ?? 'Load Failed',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 删除按钮
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 36, color: Colors.grey),
            const SizedBox(height: 8),
            Text(_l10n?.seller_auth_application_upload_file ?? 'Upload File', style: const TextStyle(color: Colors.grey)),
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
                TextSpan(text: _l10n?.seller_auth_application_agreement_read ?? 'I have read and agree to '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _showAgreement,
                    child: Text(
                      _l10n?.seller_auth_application_agreement_link ?? 'Service Agreement',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: _l10n?.seller_auth_application_agreement_guarantee ?? ' and guarantee information authenticity'),
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
        title: Text(_l10n?.seller_auth_application_agreement_title ?? 'Service Agreement'),
        content: SingleChildScrollView(
          child: Text(
            _l10n?.seller_auth_application_agreement_content ?? 'Agreement content...'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_l10n?.seller_auth_application_agreement_close ?? 'Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_l10n?.seller_auth_application_agreement_agree ?? 'Agree'),
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
        title: Text(_l10n?.seller_auth_application_submit_success ?? 'Submitted Successfully'),
        content: Text(_l10n?.seller_auth_application_submit_success_desc ?? 'Your application has been submitted and will be reviewed within 1-3 business days.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 返回上一页
              
              // 修复：返回认证管理页面时刷新状态
              // 可以通过结果回调来通知刷新
            },
            child: Text(_l10n?.seller_auth_application_ok ?? 'OK'),
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
      _showErrorSnackBar(_l10n?.seller_auth_application_select_file_failed?.call(e.toString()) ?? 'Failed to select file: $e');
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
  
  /// 移除选择的文件
  void _removeFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      setState(() {
        _selectedFiles.removeAt(index);
        // 清除相关错误
        _fieldErrors.remove('files');
      });
    }
  }
  
  /// 根据字符串获取认证类型
  AuthenticationType _getAuthenticationTypeFromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'real_name':
        return AuthenticationType.idCard;
      case 'background':
        return AuthenticationType.education;
      case 'other':
        return AuthenticationType.profession;
      case 'corporation':
        return AuthenticationType.company;
      default:
        return AuthenticationType.other;
    }
  }
  
  /// 获取认证类型显示名称
  String _getAuthenticationTypeName(AuthenticationType type) {
    return type.displayName;
  }
  
  /// 获取认证类型描述
  String _getAuthenticationTypeDescription(AuthenticationType type) {
    return type.description;
  }
  
  /// 获取上传提示文字
  String _getUploadHint(AuthenticationType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case AuthenticationType.idCard:
        return l10n?.seller_auth_application_id_upload_hint ?? 'Please upload ID card photos';
      case AuthenticationType.education:
        return l10n?.seller_auth_application_education_upload_hint ?? 'Please upload education certificates';
      case AuthenticationType.profession:
        return l10n?.seller_auth_application_profession_upload_hint ?? 'Please upload professional certificates';
      case AuthenticationType.company:
        return l10n?.seller_auth_application_company_upload_hint ?? 'Please upload business license';
      default:
        return l10n?.seller_auth_application_default_upload_hint ?? 'Please upload related materials';
    }
  }
  
  /// 安全获取本地化文本
  AppLocalizations? get _l10n => AppLocalizations.of(context);
} 