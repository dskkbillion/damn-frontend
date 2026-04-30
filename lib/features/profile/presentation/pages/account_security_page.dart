import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';
import 'package:dskk_flutter_refactor/core/utils/image_upload_helper.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import '../pages/bind_contact_page.dart';
import '../bloc/bind_contact_cubit.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

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
    _profileBloc.add(const GetUserProfileEvent());
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
                print('【退出登录】用户已成功登出，正在重定向到登录页面...');
                context.go('/auth/login');
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => current is ProfileLoggingOut,
            listener: (context, state) {
              if (state is ProfileLoggingOut) {
                print('【退出登录】正在处理登出请求...');
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => 
              current is ProfileError && 
              (previous is ProfileLoggingOut || previous is LogoutEvent),
            listener: (context, state) {
              if (state is ProfileError) {
                print('【退出登录】发生错误: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).profile_logout_error(state.message))),
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
                // 上传成功，使用新的头像URL更新用户资料
                _profileBloc.add(UpdateUserProfileEvent(avatar: state.avatarUrl));
                
                setState(() {
                  avatarResult = null; // 清除本地处理结果
                });
              } else if (state is ProfileAvatarUploadError) {
                setState(() {
                  avatarResult = null; // 清除本地处理结果
                });
                
                // 显示错误提示，便于调试
                final errorMessage = state.message.toString();
                String userFriendlyMessage;
                if (errorMessage.contains('timeout') || errorMessage.contains('超时')) {
                  userFriendlyMessage = AppLocalizations.of(context).profile_avatar_upload_timeout;
                } else if (errorMessage.contains('network') || errorMessage.contains('网络')) {
                  userFriendlyMessage = AppLocalizations.of(context).profile_network_failed;
                } else {
                  userFriendlyMessage = AppLocalizations.of(context).profile_avatar_upload_failed;
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(userFriendlyMessage),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          // 添加昵称修改成功的状态监听
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) => 
              current is ProfileUpdated && 
              previous is ProfileUpdating,
            listener: (context, state) {
              if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).profile_info_updated),
                    duration: const Duration(seconds: 2),
                  ),
                );
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
            } else if (state is ProfileAvatarUploading) {
              profile = state.profile;
            } else if (state is ProfileAvatarUploaded) {
              profile = state.profile;
            } else if (state is ProfileAvatarUploadError) {
              profile = state.profile;
            }
            
            print('[AccountSecurityPage] Current state: ${state.runtimeType}');
            print('[AccountSecurityPage] Profile: ${profile?.nickName}');
            
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context).profile_account_security),
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
    final String nickname = profile?.nickName ?? AppLocalizations.of(context).profile_default_name;
    final String? avatarUrl = profile?.avatarUrl;
    final bool hasAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    
    return Container(
      width: double.infinity,
      color: AppColors.backgroundCard,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: AppColors.borderInput,
                child: avatarResult != null
                  ? Image.file(
                      avatarResult!.finalFile,
                      fit: BoxFit.cover,
                    )
                  : hasAvatarUrl
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const Center(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: ShimmerEffect(child: CircleAvatar()),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.onPrimary,
                        ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.onPrimary,
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
              color: AppColors.textPrimary,
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
                content: Text(AppLocalizations.of(context).profile_avatar_optimized(result.compressionRatio!.toStringAsFixed(1))),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          // 显示确认对话框
          _showAvatarConfirmDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).profile_avatar_process_failed(result.error.toString()))),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profile_image_pick_error(e.toString()))),
      );
    }
  }

  void _showAvatarConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).profile_update_avatar),
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
            Text(AppLocalizations.of(context).profile_update_avatar_confirm),
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
            child: Text(AppLocalizations.of(context).profile_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadAvatar();
            },
            child: Text(AppLocalizations.of(context).profile_confirm),
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
    final String nickname = profile?.nickName ?? AppLocalizations.of(context).profile_default_name;
    final String phoneNumber = profile?.mobile ?? '';
    
    return Container(
      color: AppColors.backgroundCard,
      child: Column(
        children: [
          _buildMenuItem(
            AppLocalizations.of(context).profile_nickname,
            trailing: Text(
              nickname,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _navigateToEditNickname(profile),
          ),
          Divider(height: 1, color: AppColors.backgroundSecondary),
          _buildMenuItem(
            AppLocalizations.of(context).profile_bound_phone,
            trailing: Text(
              phoneNumber.isNotEmpty ? _maskPhoneNumber(phoneNumber) : AppLocalizations.of(context).profile_not_bound,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _navigateToBindContact(),
          ),
          Divider(height: 1, color: AppColors.backgroundSecondary),
          _buildMenuItem(
            AppLocalizations.of(context).profile_account_deletion,
            onTap: () => _showFeatureNotImplemented(AppLocalizations.of(context).profile_account_deletion),
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
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textTertiary,
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
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
          child: Text(AppLocalizations.of(context).profile_logout),
        ),
      ),
    );
  }

  void _navigateToChangeContact(String contactType, String currentContact) async {
    final result = await context.push<bool>(
      Uri(
        path: '/profile/change-contact',
        queryParameters: {
          'contactType': contactType,
          'currentContact': currentContact,
        },
      ).toString(),
    );
    if (result == true) {
      _profileBloc.add(const GetUserProfileEvent());
    }
  }

  void _navigateToUnbindContact(String contactType, String currentContact) async {
    final result = await context.push<bool>(
      Uri(
        path: '/profile/unbind-contact',
        queryParameters: {
          'contactType': contactType,
          'currentContact': currentContact,
        },
      ).toString(),
    );
    if (result == true) {
      _profileBloc.add(const GetUserProfileEvent());
    }
  }

  void _navigateToBindContact() {
    // TODO(Step1.4): BindContactPage 待路由注册后迁移到 GoRouter (需要 BlocProvider)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BindContactPage(contactType: BindContactType.phone),
      ),
    );
  }

  void _navigateToEditNickname(UserProfile? profile) async {
    // TODO(Step1.4): EditNicknamePage 待路由注册后迁移到 GoRouter
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
      _profileBloc.add(const GetUserProfileEvent());
    }
  }

  void _showFeatureNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).profile_feature_not_implemented(feature))),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).profile_confirm_logout),
          content: Text(AppLocalizations.of(context).profile_confirm_logout_message),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).profile_cancel),
            ),
            TextButton(
              onPressed: () {
                context.pop(); // 关闭对话框

                print('【退出登录】用户确认退出登录，即将发送LogoutEvent...');
                // 直接使用_profileBloc实例触发登出事件
                _profileBloc.add(LogoutEvent());
              },
              child: Text(AppLocalizations.of(context).profile_confirm),
            ),
          ],
        );
      },
    );
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length > 8) {
      return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
    }
    return phone;
  }
}

class EditNicknamePage extends StatefulWidget {
  final UserProfile? currentProfile; // 添加参数传递当前资料
  
  const EditNicknamePage({
    super.key,
    this.currentProfile,
  });

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
    final s = AppLocalizations.of(context);

    // 检查长度
    if (trimmed.isEmpty) {
      return s.profile_nickname_empty;
    }

    if (trimmed.length < 2) {
      return s.profile_nickname_too_short;
    }

    if (trimmed.length > 20) {
      return s.profile_nickname_too_long;
    }

    // 检查是否包含空格
    if (trimmed.contains(' ')) {
      return s.profile_nickname_no_spaces;
    }

    // 检查是否包含非法字符（只允许中文、英文、数字、下划线）
    final validPattern = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_]+$');
    if (!validPattern.hasMatch(trimmed)) {
      return s.profile_nickname_invalid_chars;
    }

    // 检查是否只包含特殊字符
    final onlySpecialChars = RegExp(r'^[_]+$');
    if (onlySpecialChars.hasMatch(trimmed)) {
      return s.profile_nickname_only_underscores;
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
        validationError = AppLocalizations.of(context).profile_nickname_unchanged;
      }
    } else {
      validationError = AppLocalizations.of(context).profile_nickname_empty;
    }
    
    // 按钮可用条件：
    // 1. 昵称格式合法（validationError == null）
    // 2. 不在加载中
    final shouldEnable = !_isLoading && validationError == null;
    
    // 调试信息
    print('[EditNickname] 输入文本: "$inputText"');
    print('[EditNickname] 处理后昵称: "$newNickname"');
    print('[EditNickname] 当前昵称: "$currentNickname"');
    print('[EditNickname] 验证错误: $validationError');
    print('[EditNickname] 按钮应该可用: $shouldEnable');
    print('[EditNickname] 当前按钮状态: $_isButtonEnabled');
    
    // 只有在状态发生变化时才更新UI
    if (shouldEnable != _isButtonEnabled || validationError != _validationError) {
      setState(() {
        _isButtonEnabled = shouldEnable;
        _validationError = validationError;
      });
      print('[EditNickname] 状态已更新 - 按钮可用: $_isButtonEnabled');
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
              SnackBar(content: Text(AppLocalizations.of(context).profile_nickname_updated)),
            );
            
            // 返回并刷新父页面
            Navigator.pop(context, true);
          } else if (state is ProfileError) {
            setState(() {
              _isLoading = false;
            });
            _updateButtonState(); // 更新按钮状态
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).profile_nickname_update_failed(state.message))),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).profile_edit_nickname_title),
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
                    // 只允许中文、英文、数字、下划线，禁止空格和其他特殊字符
                    FilteringTextInputFormatter.allow(RegExp(r'[\u4e00-\u9fa5a-zA-Z0-9_]')),
                  ],
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).profile_nickname_input_hint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: AppColors.borderInput),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  maxLength: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    AppLocalizations.of(context).profile_nickname_rules,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
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
                          ? AppColors.primary
                          : AppColors.borderInput,
                      foregroundColor: _isButtonEnabled
                          ? AppColors.onPrimary
                          : AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: _isButtonEnabled ? 2 : 0,
                      // 确保按钮状态变化时能正确更新
                      disabledBackgroundColor: AppColors.borderInput,
                      disabledForegroundColor: AppColors.textSecondary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context).profile_submit_changes,
                            style: const TextStyle(
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
        SnackBar(content: Text(AppLocalizations.of(context).profile_nickname_unchanged)),
      );
      return;
    }
    
    // 调用BLoC更新昵称
    _profileBloc.add(UpdateUserProfileEvent(nickName: newNickname));
  }
}
