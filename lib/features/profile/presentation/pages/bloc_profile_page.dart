import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../../../seller/presentation/pages/seller_profile_page.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

class BlocProfilePage extends StatefulWidget {
  const BlocProfilePage({super.key});

  @override
  State<BlocProfilePage> createState() => _BlocProfilePageState();
}

class _BlocProfilePageState extends State<BlocProfilePage> {
  @override
  void initState() {
    super.initState();
    // 获取ProfileBloc实例并触发初始事件
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ProfileAvatarUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).profile_avatar_uploaded)),
          );
          // 更新上传头像后获取最新用户信息
          context.read<ProfileBloc>().add(const GetUserProfileEvent());
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).profile_updated)),
          );
        } else if (state is ProfileAuthStatusLoaded) {
          if (state.isAuthenticated) {
            // 如果已登录，获取用户信息
            context.read<ProfileBloc>().add(const GetUserProfileEvent());
          } else {
            // 如果未登录，可以导航到登录页面
            // Navigator.pushReplacementNamed(context, '/login');
          }
        } else if (state is ProfileSwitchedToSellerMode) {
          // 🔄 买家→卖家：翻转动画（绕垂直轴）
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => SellerProfilePage(
                onSwitchToBuyer: () {
                  context.read<ProfileBloc>().add(const SwitchToBuyerModeEvent());
                },
              ),
              transitionDuration: const Duration(milliseconds: 600),
              reverseTransitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // 🎯 翻转动画：围绕Y轴（垂直轴）旋转
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final rotationValue = animation.value * 3.14159; // 0 到 π
                    
                    if (rotationValue >= 3.14159 / 2) {
                      // 后半段：显示新页面
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 透视效果
                          ..rotateY(3.14159),
                        child: child,
                      );
                    } else {
                      // 前半段：隐藏旧页面
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(rotationValue),
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      );
                    }
                  },
                  child: child,
                );
              },
            ),
          );
        } else if (state is ProfileSwitchedToBuyerMode) {
          // 🔄 卖家→买家：翻转动画（绕垂直轴）
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const BlocProfilePage(),
              transitionDuration: const Duration(milliseconds: 600),
              reverseTransitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // 🎯 翻转动画：围绕Y轴（垂直轴）旋转
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final rotationValue = animation.value * 3.14159; // 0 到 π
                    
                    if (rotationValue >= 3.14159 / 2) {
                      // 后半段：显示新页面
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 透视效果
                          ..rotateY(3.14159),
                        child: child,
                      );
                    } else {
                      // 前半段：隐藏旧页面
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(rotationValue),
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      );
                    }
                  },
                  child: child,
                );
              },
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).profile_personal_center)),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProfileLoaded || state is ProfileUpdated || state is ProfileAvatarUploaded) {
          // 显示已加载的用户资料
          final UserProfile profile = state is ProfileLoaded
              ? state.profile
              : state is ProfileUpdated
                  ? state.profile
                  : (context.read<ProfileBloc>().state as ProfileLoaded).profile;

          return _buildUserProfilePage(context, profile);
        } else {
          // 默认内容
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context).profile_personal_center)),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(const GetUserProfileEvent());
                },
                child: Text(AppLocalizations.of(context).profile_reload),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildUserProfilePage(BuildContext context, UserProfile profile) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile_personal_center),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 导航到设置页面
              // Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(const GetUserProfileEvent());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return const ProfileHeader();
                },
              ),
              const SizedBox(height: 16),
              _buildWalletSection(context),
              const SizedBox(height: 16),
              _buildOrderStatusSection(),
              const SizedBox(height: 16),
              _buildMenuSection(context),
              const SizedBox(height: 24),
              _buildSellerModeButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final bool isLoading = state is WalletSummaryLoading;

        return GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              // 导航到钱包详情页
              // Navigator.pushNamed(context, '/wallet');
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).profile_my_wallet,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: isLoading
                            ? null
                            : () => context.read<ProfileBloc>().add(GetWalletSummaryEvent()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state is WalletSummaryLoaded)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¥ ${state.walletSummary.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(AppLocalizations.of(context).profile_account_balance),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context).profile_pending_settlement),
                                const SizedBox(height: 4),
                                Text('${RegionConfig.currencySymbol} ${state.walletSummary.pendingAmount?.toStringAsFixed(2) ?? '0.00'}'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context).profile_total_income),
                                const SizedBox(height: 4),
                                Text('${RegionConfig.currencySymbol} ${state.walletSummary.totalIncome?.toStringAsFixed(2) ?? '0.00'}'),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ],
                    )
                  else
                    Center(
                      child: TextButton(
                        onPressed: () => context.read<ProfileBloc>().add(GetWalletSummaryEvent()),
                        child: Text(AppLocalizations.of(context).profile_load_wallet),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusSection() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).profile_my_orders,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 导航到全部订单页面
                    // Navigator.pushNamed(context, '/orders');
                  },
                  child: Row(
                    children: [
                      Text(AppLocalizations.of(context).profile_all_orders, style: const TextStyle(color: AppColors.textTertiary)),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrderStatusItem(icon: Icons.payment, label: AppLocalizations.of(context).profile_awaiting_payment, badge: 2),
                _buildOrderStatusItem(icon: Icons.local_shipping, label: AppLocalizations.of(context).profile_awaiting_shipment),
                _buildOrderStatusItem(icon: Icons.inventory, label: AppLocalizations.of(context).profile_awaiting_receipt, badge: 1),
                _buildOrderStatusItem(icon: Icons.star_border, label: AppLocalizations.of(context).profile_awaiting_review),
                _buildOrderStatusItem(icon: Icons.undo, label: AppLocalizations.of(context).profile_refund_after_sales),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem({
    required IconData icon,
    required String label,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: () {
        // 导航到对应订单状态页面
        // Navigator.pushNamed(context, '/orders', arguments: {'status': label});
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28),
              if (badge > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final s = AppLocalizations.of(context);
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.location_on, 'title': s.profile_shipping_address, 'route': '/address'},
      {'icon': Icons.favorite, 'title': s.profile_favorites, 'route': '/favorites'},
      {'icon': Icons.history, 'title': s.profile_browsing_history, 'route': '/history'},
      {'icon': Icons.headset_mic, 'title': s.profile_contact_support, 'route': '/customer-service'},
      {'icon': Icons.help, 'title': s.profile_help_center, 'route': '/help'},
      {'icon': Icons.feedback, 'title': s.profile_feedback, 'route': '/feedback'},
    ];

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () {
              // 导航到对应页面
              // Navigator.pushNamed(context, item['route']!);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, size: 24),
                const SizedBox(height: 8),
                Text(item['title']!, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSellerModeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ProfileBloc>().add(const SwitchToSellerModeEvent());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).profile_switch_to_seller_mode,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppLocalizations.of(context).profile_take_photo),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).profile_choose_from_album),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        context.read<ProfileBloc>().add(UploadAvatarEvent(imageFile: File(image.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profile_image_pick_failed(e.toString()))),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final TextEditingController nickNameController = TextEditingController(text: profile.nickName);
    bool onlineFlag = profile.onlineFlag ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).profile_edit_profile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nickNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).profile_nickname,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(AppLocalizations.of(context).profile_online_status),
                const Spacer(),
                Switch(
                  value: onlineFlag,
                  onChanged: (value) {
                    onlineFlag = value;
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).profile_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(
                    UpdateUserProfileEvent(
                      nickName: nickNameController.text,
                      onlineFlag: onlineFlag,
                    ),
                  );
            },
            child: Text(AppLocalizations.of(context).profile_save),
          ),
        ],
      ),
    );
  }
}
