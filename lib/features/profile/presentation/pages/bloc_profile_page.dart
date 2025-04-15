import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/profile_bloc.dart';
import '../../../../core/usecases/usecase.dart';

class BlocProfilePage extends StatelessWidget {
  const BlocProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取ProfileBloc实例并触发初始事件
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(CheckAuthStatusEvent());

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ProfileLoggedOut) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已退出登录')),
          );
        } else if (state is ProfileSwitchedToSellerMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已切换到卖家模式')),
          );
        } else if (state is ProfileSwitchedToBuyerMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已切换到买家模式')),
          );
        } else if (state is ProfileAvatarUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像上传成功')),
          );
          // 重新加载用户资料
          context.read<ProfileBloc>().add(GetUserProfileEvent());
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('信息更新成功')),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileAuthStatusLoaded) {
          if (!state.isAuthenticated) {
            return _buildLoginPrompt(context);
          } else if (state is! ProfileLoaded && state is! ProfileUpdated) {
            context.read<ProfileBloc>().add(GetUserProfileEvent());
          }
        }

        // 构建主页面
        return _buildMainContent(context, state);
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '请登录以查看您的个人资料',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 导航到登录页面 (在实际应用中会使用导航服务)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导航到登录页面')),
                );
              },
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileState state) {
    final profile = state is ProfileLoaded
        ? state.profile
        : (state is ProfileUpdated ? state.profile : null);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(GetUserProfileEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部
                _buildHeader(context, profile, state),

                // 我的订单
                _buildSection(
                  context,
                  '我的订单',
                  [
                    _buildMenuItem(
                      context,
                      Icons.access_time,
                      '待付款',
                      () => _showStatusMessage(context, '导航到待付款订单列表'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.sync,
                      '进行中',
                      () => _showStatusMessage(context, '导航到进行中订单列表'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.check_circle,
                      '已完成',
                      () => _showStatusMessage(context, '导航到已完成订单列表'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.undo,
                      '退款/售后',
                      () => _showStatusMessage(context, '导航到退款/售后订单列表'),
                    ),
                  ],
                  isGrid: true,
                ),

                // 我的关看
                _buildSection(
                  context,
                  '我的关看',
                  [
                    _buildMenuItem(
                      context,
                      Icons.star_border,
                      '收藏',
                      () => _showStatusMessage(context, '导航到收藏列表'),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.favorite_border,
                      '点赞的故事',
                      () => _showStatusMessage(context, '导航到点赞的故事'),
                    ),
                  ],
                  isGrid: false,
                ),

                // 我的钱包
                _buildSection(
                  context,
                  '我的钱包',
                  [
                    _buildMenuItem(
                      context,
                      Icons.account_balance_wallet,
                      '钱包',
                      () => _showStatusMessage(context, '导航到钱包页面'),
                    ),
                  ],
                  isGrid: false,
                ),

                // 设置
                _buildSection(
                  context,
                  '设置',
                  [
                    _buildMenuItem(
                      context,
                      Icons.security,
                      '账号与安全',
                      () => _showStatusMessage(context, '导航到账号与安全页面'),
                    ),
                  ],
                  isGrid: false,
                ),

                // 登出按钮
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认登出'),
                            content: const Text('您确定要退出登录吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<ProfileBloc>().add(LogoutEvent());
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('退出登录'),
                    ),
                  ),
                ),

                // 底部空间
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic profile, ProfileState state) {
    // 检查当前是否为卖家模式
    bool isSellerMode = state is ProfileSwitchedToSellerMode;

    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 用户信息
          Row(
            children: [
              // 头像
              GestureDetector(
                onTap: () => _showImagePicker(context),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profile?.avatarUrl != null
                      ? (profile!.avatarUrl!.startsWith('assets/')
                          ? AssetImage(profile.avatarUrl!)
                          : NetworkImage(profile.avatarUrl!) as ImageProvider)
                      : null,
                  child: profile?.avatarUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // 用户名称和状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showEditNicknameDialog(context, profile?.nickName),
                    child: Text(
                      profile?.nickName ?? '用户',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: profile?.onlineFlag == true ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile?.onlineFlag == true ? '在线' : '离线',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 卖家模式开关
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '卖家模式',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: isSellerMode, // 根据当前状态设置开关值
                  onChanged: (value) {
                    if (value) {
                      // 切换到卖家模式
                      context.read<ProfileBloc>().add(const SwitchToSellerModeEvent());
                    } else {
                      // 切换到买家模式
                      context.read<ProfileBloc>().add(const SwitchToBuyerModeEvent());
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> items,
    {bool isGrid = false}
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (isGrid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items,
            )
          else
            Column(
              children: items,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    if (text == '待付款' || text == '进行中' || text == '已完成' || text == '退款/售后') {
      // 订单状态样式
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 菜单项样式
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () async {
              Navigator.pop(context);
              _pickImage(context, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () async {
              Navigator.pop(context);
              _pickImage(context, ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        context.read<ProfileBloc>().add(
          UploadAvatarEvent(imageFile: File(pickedFile.path))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: ${e.toString()}')),
      );
    }
  }

  void _showEditNicknameDialog(BuildContext context, String? currentNickname) {
    final TextEditingController controller = TextEditingController(text: currentNickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入新昵称',
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final String newNickname = controller.text.trim();
              if (newNickname.isNotEmpty) {
                context.read<ProfileBloc>().add(
                  UpdateUserProfileEvent(nickName: newNickname)
                );
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showStatusMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
