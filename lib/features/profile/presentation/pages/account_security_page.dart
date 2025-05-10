import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({Key? key}) : super(key: key);

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  File? avatarFile; // 仅用于本地选择的头像
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
            listenWhen: (previous, current) => current is ProfileError,
            listener: (context, state) {
              if (state is ProfileError) {
                print('【退出登录】发生错误: ${state.message}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('退出登录时发生错误: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 从state中提取用户资料
            UserProfile? profile;
            if (state is ProfileLoaded) {
              profile = state.profile;
            } else if (state is ProfileUpdated) {
              profile = state.profile;
            }
            
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
                child: avatarFile != null
                  ? Image.file(
                      avatarFile!,
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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          avatarFile = File(pickedFile.path);
        });
        // 显示提示
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像已更新，但尚未保存到服务器')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片时出错: $e')),
      );
    }
  }

  Widget _buildMenuItems(UserProfile? profile) {
    final String nickname = profile?.nickName ?? '用户';
    // UserProfile中没有phoneNumber属性，使用硬编码的示例号码
    final String phoneNumber = '18888888888';
    
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
            onTap: () => _navigateToEditNickname(),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            '已绑定手机号',
            trailing: Text(
              _maskPhoneNumber(phoneNumber),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () => _showFeatureNotImplemented('更换手机号'),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            '账号注销',
            onTap: () => _showFeatureNotImplemented('账号注销'),
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

  void _navigateToEditNickname() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditNicknamePage(),
      ),
    );
  }

  void _showFeatureNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature功能尚未实现')),
    );
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
                
                print('【退出登录】用户确认退出登录，即将发送LogoutEvent...');
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
    if (phone.length > 8) {
      return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
    }
    return phone;
  }
}

class EditNicknamePage extends StatefulWidget {
  const EditNicknamePage({Key? key}) : super(key: key);

  @override
  State<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends State<EditNicknamePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = '瑞'; // 初始化为当前昵称
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑昵称'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '请输入',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              maxLength: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '请设置2-20个字符，不包括空格等无效字符',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 模拟提交修改
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('昵称修改功能尚未实现')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
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
    );
  }
}
