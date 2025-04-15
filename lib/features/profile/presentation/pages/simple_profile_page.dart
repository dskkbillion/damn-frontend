import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SimpleProfilePage extends StatefulWidget {
  const SimpleProfilePage({Key? key}) : super(key: key);

  @override
  State<SimpleProfilePage> createState() => _SimpleProfilePageState();
}

class _SimpleProfilePageState extends State<SimpleProfilePage> {
  // 模拟用户数据
  String userName = '用户名';
  bool isOnline = false;
  String? avatarUrl;
  File? avatarFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 头部
              _buildHeader(context),

              // 我的订单
              _buildSection(
                context,
                '我的订单',
                [
                  _buildMenuItem(context, Icons.access_time, '待付款', () {
                    _showStatusMessage('导航到待付款订单列表');
                  }),
                  _buildMenuItem(context, Icons.sync, '进行中', () {
                    _showStatusMessage('导航到进行中订单列表');
                  }),
                  _buildMenuItem(context, Icons.check_circle, '已完成', () {
                    _showStatusMessage('导航到已完成订单列表');
                  }),
                  _buildMenuItem(context, Icons.undo, '退款/售后', () {
                    _showStatusMessage('导航到退款/售后订单列表');
                  }),
                ],
                isGrid: true,
              ),

              // 我的关看
              _buildSection(
                context,
                '我的关看',
                [
                  _buildMenuItem(context, Icons.star_border, '收藏', () {
                    _showStatusMessage('导航到收藏列表');
                  }),
                  _buildMenuItem(context, Icons.favorite_border, '点赞的故事', () {
                    _showStatusMessage('导航到点赞的故事');
                  }),
                ],
                isGrid: false,
              ),

              // 我的钱包
              _buildSection(
                context,
                '我的钱包',
                [
                  _buildMenuItem(context, Icons.account_balance_wallet, '钱包', () {
                    _showStatusMessage('导航到钱包页面');
                  }),
                ],
                isGrid: false,
              ),

              // 设置
              _buildSection(
                context,
                '设置',
                [
                  _buildMenuItem(context, Icons.security, '账号与安全', () {
                    _showStatusMessage('导航到账号与安全页面');
                  }),
                ],
                isGrid: false,
              ),

              // 登出按钮
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('退出登录'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                onTap: _showImagePicker,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarFile != null
                      ? FileImage(avatarFile!)
                      : (avatarUrl != null ? NetworkImage(avatarUrl!) as ImageProvider : null),
                  child: (avatarFile == null && avatarUrl == null)
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // 用户信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _showEditNameDialog,
                    child: Text(
                      userName,
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
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? '在线' : '离线',
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
                  value: false,
                  onChanged: (value) {
                    if (value) {
                      _showStatusMessage('切换到卖家模式');
                    }
                  },
                  activeColor: Colors.green,
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
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

  // 显示头像选择器
  Future<void> _showImagePicker() async {
    final ImagePicker picker = ImagePicker();

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
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  avatarFile = File(image.path);
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? image = await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                setState(() {
                  avatarFile = File(image.path);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // 显示编辑名称对话框
  void _showEditNameDialog() {
    final TextEditingController controller = TextEditingController(text: userName);

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
              final String newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  userName = newName;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 登出
  void _logout() {
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
              _showStatusMessage('已退出登录');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 显示状态消息
  void _showStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
