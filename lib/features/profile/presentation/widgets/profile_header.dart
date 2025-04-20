import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/profile_bloc.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileState state;

  const ProfileHeader({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 用户信息
          _buildUserInfo(context, state),

          const SizedBox(height: 16),

          // 卖家模式切换
          _buildSellerModeSwitch(context),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ProfileState state) {
    // 从状态中获取用户资料
    final profile = state is ProfileLoaded
        ? state.profile
        : (state is ProfileUpdated ? state.profile : null);

    return Row(
      children: [
        // 头像
        InkWell(
          onTap: () => _showAvatarOptions(context),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: profile?.avatarUrl != null
                ? NetworkImage(profile!.avatarUrl!)
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
            InkWell(
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
    );
  }

  Widget _buildSellerModeSwitch(BuildContext context) {
    return Container(
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
            value: false, // 默认为买家模式
            onChanged: (value) {
              if (value) {
                // 切换到卖家模式
                context.read<ProfileBloc>().add(SwitchToSellerModeEvent());
              }
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(context, ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () {
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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

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
    final textController = TextEditingController(text: currentNickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: textController,
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
              final newNickname = textController.text.trim();
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
}
