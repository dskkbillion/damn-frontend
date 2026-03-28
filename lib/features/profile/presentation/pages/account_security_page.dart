import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dio/dio.dart';
import 'bind_contact_page.dart';
import '../bloc/bind_contact_cubit.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({Key? key}) : super(key: key);

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  ImageProcessResult? avatarResult; // 使用ImageProcessResult而不是直接的File
  late ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = GetIt.instance<ProfileBloc>();
    // 立即加载用户资料
    _profileBloc.add(GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc, // 使用已初始化的bloc实例
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => current is ProfileLoggedOut,
            listener: (context, state) {
              if (state is ProfileLoggedOut) {
                // 登出成功后导航到登录页面，并清除导航栈
                AppLogger.d('【退出登录】用户已成功登出，正在重定向到登录页面...');
                context.go('/auth/login');
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => current is ProfileLoggingOut,
            listener: (context, state) {
              if (state is ProfileLoggingOut) {
                AppLogger.d('【退出登录】正在处理登出请求...');
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => 
              current is ProfileError && 
              (previous is ProfileLoggingOut || previous is LogoutEvent),
            listener: (context, state) {
              if (state is ProfileError) {
                AppLogger.d('【退出登录】发生错误: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('退出登录时发生错误: ${state.message}')),
                );
              }
            },
          ),
          // 添加头像上传状态监听
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => 
              current is ProfileAvatarUploading ||
              current is ProfileAvatarUploaded ||
              current is ProfileAvatarUploadError,
            listener: (context, state) {
              if (state is ProfileAvatarUploaded) {
                // 上传成功后，立即更新用户资料
                AppLogger.d('[AccountSecurityPage] Avatar uploaded successfully, updating profile with URL: ${state.avatarUrl}');
                _profileBloc.add(UpdateUserProfileEvent(avatar: state.avatarUrl));

                setState(() {
                  avatarResult = null; // 清除本地处理结果
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('头像上传成功，正在更新资料...'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is ProfileAvatarUploadError) {
                setState(() {
                  avatarResult = null; // 清除本地处理结果
                });
                
                // 显示错误提示，便于调试
                final errorMessage = state.message.toString();
                String userFriendlyMessage;
                if (errorMessage.contains('timeout') || errorMessage.contains('超时')) {
                  userFriendlyMessage = '头像上传超时，请检查网络连接后重试';
                } else if (errorMessage.contains('network') || errorMessage.contains('网络')) {
                  userFriendlyMessage = '网络连接失败，请检查网络后重试';
                } else {
                  userFriendlyMessage = '头像上传失败，请重试';
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(userFriendlyMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          // 添加个人信息更新成功的状态监听
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
              current is ProfileUpdated &&
              (previous is ProfileUpdating || previous is ProfileAvatarUploaded),
            listener: (context, state) {
              if (state is ProfileUpdated) {
                AppLogger.d('[AccountSecurityPage] Profile updated successfully');
                // 不再显示重复的提示，因为头像更新已经有自己的提示
                if (!(state is ProfileUpdated && context.read<ProfileBloc>().state is ProfileAvatarUploaded)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('个人信息更新成功！'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 从state中提取用户资料，支持所有包含用户信息的状态
            UserProfile? profile;
            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileUpdated) {
              profile = state.profile;
            } else if (state is ProfileUpdating) {
              profile = state.profile;
            } else if (state is ProfileAvatarUploading) {
              profile = state.profile;
            } else if (state is ProfileAvatarUploaded) {
              profile = state.profile;
            } else if (state is ProfileAvatarUploadError) {
              profile = state.profile;
            }
            
            AppLogger.d('[AccountSecurityPage] Current state: ${state.runtimeType}');
            AppLogger.d('[AccountSecurityPage] Profile: ${profile?.nickName}');
            
            return Scaffold(
              appBar: AppBar(
                title: const Text('账号与安全'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => context.pop(),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileAvatar(profile),
                    const SizedBox(height: 10),
                    _buildMenuItems(profile),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 不要关闭_profileBloc，因为它可能在别处被使用
    super.dispose();
  }

  Widget _buildProfileAvatar(UserProfile? profile) {
    final String nickname = profile?.nickName ?? '用户';
    final String? avatarUrl = profile?.avatarUrl;
    final bool hasAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade300,
                child: avatarResult != null
                  ? Image.file(
                      avatarResult!.finalFile,
                      fit: BoxFit.cover,
                    )
                  : hasAvatarUrl
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nickname,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    try {
      // Use ImageUploadHelper for avatar processing
      final results = await ImageUploadHelper.pickFromGallery(
        type: ImageUploadType.avatar,
        allowMultiple: false,
      );

      if (results.isNotEmpty) {
        final result = results.first;
        
        if (result.isSuccess) {
          setState(() {
            avatarResult = result;
          });
          
          // 显示压缩信息和确认对话框
          if (result.compressionRatio != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('头像已优化处理，压缩 ${result.compressionRatio!.toStringAsFixed(1)}%'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          // 显示确认对话框
          _showAvatarConfirmDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('头像处理失败: ${result.error}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片时出错: $e')),
      );
    }
  }

  void _showAvatarConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatarResult != null)
              ClipOval(
                child: Image.file(
                  avatarResult!.finalFile,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            const Text('确定要更新头像吗？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                avatarResult = null; // 取消选择
              });
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadAvatar();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _uploadAvatar() {
    if (avatarResult != null) {
      // 调用BLoC上传头像，使用处理后的文件
      _profileBloc.add(UploadAvatarEvent(imageFile: avatarResult!.finalFile));
    }
  }

  Widget _buildMenuItems(UserProfile? profile) {
    final String nickname = profile?.nickName ?? '用户';
    final String phoneNumber = profile?.mobile ?? '';
    final String emailAddress = profile?.email ?? '';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuItem(
            '昵称',
            trailing: Text(
              nickname,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () => _navigateToEditNickname(profile),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            '手机号',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phoneNumber.isNotEmpty ? _maskPhoneNumber(phoneNumber) : '未绑定',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (phoneNumber.isEmpty) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '绑定',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB66D0E),
                    ),
                  ),
                ],
              ],
            ),
            onTap: phoneNumber.isEmpty
                ? () => _navigateToBindContact(BindContactType.phone)
                : null,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            '邮箱',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emailAddress.isNotEmpty ? _maskEmail(emailAddress) : '未绑定',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (emailAddress.isEmpty) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '绑定',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB66D0E),
                    ),
                  ),
                ],
              ],
            ),
            onTap: emailAddress.isEmpty
                ? () => _navigateToBindContact(BindContactType.email)
                : null,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            '账号注销',
            onTap: () => _showDeactivateAccountDialog(profile),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(context),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
          child: const Text('退出登录'),
        ),
      ),
    );
  }

  void _navigateToEditNickname(UserProfile? profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNicknamePage(
          currentProfile: profile, // 传递当前用户资料
        ),
      ),
    );
    
    // 如果编辑成功，刷新当前页面数据
    if (result == true) {
      _profileBloc.add(GetUserProfileEvent());
    }
  }

  void _navigateToBindContact(BindContactType contactType) async {
    final dio = GetIt.instance<Dio>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => BindContactCubit(dio: dio),
          child: BindContactPage(contactType: contactType),
        ),
      ),
    );

    // 绑定成功后刷新用户资料
    if (result == true) {
      _profileBloc.add(GetUserProfileEvent(skipCache: true));
    }
  }

  String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;
    final prefix = email.substring(0, 1);
    final domain = email.substring(atIndex);
    return '$prefix****$domain';
  }

  void _showDeactivateAccountDialog(UserProfile? profile) {
    const confirmText = '确认注销';
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final confirmed = controller.text == confirmText;
            return AlertDialog(
              title: const Text('注销账号'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '注销后，您的账号数据（包括订单记录、个人信息、收藏等）将被永久清除且无法恢复。',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '请输入"$confirmText"以继续',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      hintText: confirmText,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: confirmed
                      ? () {
                          controller.dispose();
                          Navigator.pop(dialogContext);
                          _submitDeactivateAccount(profile);
                        }
                      : null,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('确认注销'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitDeactivateAccount(UserProfile? profile) async {
    final dio = GetIt.instance<Dio>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await dio.post(
        '/api/project/logout/edit',
        data: {'memberId': profile?.userId},
      );
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('注销申请已提交，请等待审核')),
        );
        _profileBloc.add(LogoutEvent());
      }
    } on DioException catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('注销申请失败：${e.message}')),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                context.pop(); // 关闭对话框
                
                AppLogger.d('【退出登录】用户确认退出登录，即将发送LogoutEvent...');
                // 直接使用_profileBloc实例触发登出事件
                _profileBloc.add(LogoutEvent());
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  String _maskPhoneNumber(String phone) {
    // 处理带区号的号码（如 +8613800000001）
    if (phone.startsWith('+')) {
      // 找到区号结束位置（1-3位数字在+后面）
      final digits = phone.substring(1);
      // 保留区号+前3位本地号码，中间隐藏，露出后4位
      if (digits.length > 8) {
        return '+${digits.substring(0, 4)}****${digits.substring(digits.length - 4)}';
      }
      return phone;
    }
    // 纯国内号码（如 13800000001）
    if (phone.length > 8) {
      return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
    }
    return phone;
  }
}

class EditNicknamePage extends StatefulWidget {
  final UserProfile? currentProfile; // 添加参数传递当前资料
  
  const EditNicknamePage({
    Key? key,
    this.currentProfile,
  }) : super(key: key);

  @override
  State<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends State<EditNicknamePage> {
  final TextEditingController _controller = TextEditingController();
  late ProfileBloc _profileBloc;
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  String? _validationError;

  /// 验证昵称合法性
  /// 返回null表示合法，返回字符串表示错误信息
  String? _validateNickname(String nickname) {
    final trimmed = nickname.trim();
    
    // 检查长度
    if (trimmed.isEmpty) {
      return '请输入昵称';
    }
    
    if (trimmed.length < 2) {
      return '昵称至少需要2个字符';
    }
    
    if (trimmed.length > 20) {
      return '昵称不能超过20个字符';
    }
    
    // 检查是否包含空格
    if (trimmed.contains(' ')) {
      return '昵称不能包含空格';
    }
    
    // 检查是否包含非法字符（只允许中文、英文、数字、下划线）
    final validPattern = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return '昵称只能包含中文、英文、数字和下划线';
    }
    
    // 检查是否只包含特殊字符
    final onlySpecialChars = RegExp(r'^[_]+$');
    if (onlySpecialChars.hasMatch(trimmed)) {
      return '昵称不能只包含下划线';
    }
    
    return null; // 验证通过
  }

  @override
  void initState() {
    super.initState();
    _profileBloc = GetIt.instance<ProfileBloc>();
    
    // 添加监听器来实时更新按钮状态
    _controller.addListener(_updateButtonState);
    
    // 初始化为当前昵称
    _controller.text = widget.currentProfile?.nickName ?? '';
    
    // 延迟初始化按钮状态，确保TextController的文本已设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateButtonState();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final inputText = _controller.text;
    final newNickname = inputText.trim();
    final currentNickname = widget.currentProfile?.nickName ?? '';
    
    // 获取验证错误信息
    String? validationError;
    
    // 只有当输入不为空时才进行验证
    if (inputText.isNotEmpty) {
      validationError = _validateNickname(newNickname);
      
      // 如果昵称格式正确，但与当前昵称相同，显示提示
      if (validationError == null && newNickname == currentNickname) {
        validationError = '昵称没有变化';
      }
    } else {
      validationError = '请输入昵称';
    }
    
    // 按钮可用条件：
    // 1. 昵称格式合法（validationError == null）
    // 2. 不在加载中
    final shouldEnable = !_isLoading && validationError == null;
    
    // 调试信息
    AppLogger.d('[EditNickname] 输入文本: "$inputText"');
    AppLogger.d('[EditNickname] 处理后昵称: "$newNickname"');
    AppLogger.d('[EditNickname] 当前昵称: "$currentNickname"');
    AppLogger.d('[EditNickname] 验证错误: $validationError');
    AppLogger.d('[EditNickname] 按钮应该可用: $shouldEnable');
    AppLogger.d('[EditNickname] 当前按钮状态: $_isButtonEnabled');
    
    // 只有在状态发生变化时才更新UI
    if (shouldEnable != _isButtonEnabled || validationError != _validationError) {
      setState(() {
        _isButtonEnabled = shouldEnable;
        _validationError = validationError;
      });
      AppLogger.d('[EditNickname] 状态已更新 - 按钮可用: $_isButtonEnabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdating) {
            setState(() {
              _isLoading = true;
              _validationError = null; // 清除验证错误
            });
            _updateButtonState(); // 更新按钮状态
          } else if (state is ProfileUpdated) {
            setState(() {
              _isLoading = false;
            });
            _updateButtonState(); // 更新按钮状态
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('昵称修改成功！')),
            );
            
            // 返回并刷新父页面
            Navigator.pop(context, true);
          } else if (state is ProfileError) {
            setState(() {
              _isLoading = false;
            });
            _updateButtonState(); // 更新按钮状态
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('昵称修改失败: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('编辑昵称'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    // 不再使用 FilteringTextInputFormatter，因为它会干扰 iOS 拼音输入
                    // 验证逻辑在 _validateNickname 中处理，用户输入非法字符时按钮变灰并显示错误提示
                  ],
                  decoration: InputDecoration(
                    hintText: '请输入昵称',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLength: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '请设置2-20个字符，只能包含中文、英文、数字和下划线',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // 显示验证错误信息
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _submitNickname : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled 
                          ? const Color(0xFF1976D2) // 使用蓝色表示可用状态
                          : Colors.grey.shade300,
                      foregroundColor: _isButtonEnabled 
                          ? Colors.white 
                          : Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: _isButtonEnabled ? 2 : 0,
                      // 确保按钮状态变化时能正确更新
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '提交修改',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitNickname() {
    final newNickname = _controller.text.trim();
    
    // 验证昵称合法性
    final validationError = _validateNickname(newNickname);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    
    if (newNickname == widget.currentProfile?.nickName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称没有变化')),
      );
      return;
    }
    
    // 调用BLoC更新昵称
    _profileBloc.add(UpdateUserProfileEvent(nickName: newNickname));
  }
}
