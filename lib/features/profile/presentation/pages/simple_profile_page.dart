import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_time_settings_usecase.dart';

class SimpleProfilePage extends StatefulWidget {
  final VoidCallback? onSwitchMode;

  const SimpleProfilePage({super.key, this.onSwitchMode});

  @override
  State<SimpleProfilePage> createState() => _SimpleProfilePageState();
}

class _SimpleProfilePageState extends State<SimpleProfilePage> {
  // 模拟用户数据
  String? userName;
  bool _isOnline = true;
  String? avatarUrl;
  File? avatarFile;

  // 事件总线订阅
  StreamSubscription<SellerOnlineStatusChangedEvent>? _onlineStatusSubscription;

  @override
  void initState() {
    super.initState();
    _loadOnlineStatus();
    _onlineStatusSubscription = EventBus().sellerOnlineStatusChangedStream.listen((event) {
      if (mounted) {
        setState(() {
          _isOnline = event.isOnline;
        });
        AppLogger.d('[SimpleProfilePage] Online status updated via EventBus: ${event.isOnline}');
      }
    });
  }

  @override
  void dispose() {
    _onlineStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOnlineStatus() async {
    try {
      final getTimeSettingsUseCase = GetIt.instance<GetTimeSettingsUseCase>();
      final result = await getTimeSettingsUseCase(NoParams());
      result.fold(
        (failure) => AppLogger.d('[SimpleProfilePage] Failed to load online status: ${failure.message}'),
        (settings) {
          if (mounted) {
            setState(() {
              _isOnline = settings.isOnline;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.d('[SimpleProfilePage] Error loading online status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar
      // appBar: AppBar(
      //   title: const Text('个人中心'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('设置功能尚未实现')),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildProfileSection(
              context,
              AppLocalizations.of(context).profile_my_orders,
              _buildOrderStatusList(context)
            ),
            _buildProfileSection(
              context,
              AppLocalizations.of(context).profile_my_dskk_section,
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.star_border,
                  title: AppLocalizations.of(context).profile_favorites,
                  onTap: () => context.push('/favorites'),
                ),
                MenuItem(
                  icon: Icons.favorite_border,
                  title: AppLocalizations.of(context).profile_liked_stories,
                  onTap: () => _showFeatureNotImplemented(AppLocalizations.of(context).profile_liked_stories),
                ),
              ]),
            ),
            _buildProfileSection(
              context,
              AppLocalizations.of(context).profile_my_wallet,
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.account_balance_wallet,
                  title: AppLocalizations.of(context).profile_wallet,
                  onTap: () => _navigateToWallet(context),
                ),
              ]),
            ),
            _buildProfileSection(
              context,
              AppLocalizations.of(context).profile_settings,
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.security,
                  title: AppLocalizations.of(context).profile_account_security,
                  onTap: () => _navigateToAccountSecurity(context),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _showFeatureNotImplemented(AppLocalizations.of(context).profile_logout);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  ),
                  child: Text(AppLocalizations.of(context).profile_logout),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 用户信息
          Row(
            children: [
              // 头像
              GestureDetector(
                onTap: () => _pickImage(),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                  child: avatarFile == null ? const Icon(Icons.person, size: 40, color: AppColors.onPrimary) : null,
                ),
              ),
              const SizedBox(width: 16),

              // 用户名称和状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showFeatureNotImplemented(AppLocalizations.of(context).profile_edit_nickname),
                    child: Text(
                      userName ?? AppLocalizations.of(context).profile_user_name_default,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
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
                          color: _isOnline ? AppColors.success : AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isOnline
                            ? AppLocalizations.of(context).profile_online
                            : AppLocalizations.of(context).profile_offline,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
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
                Text(
                  AppLocalizations.of(context).profile_buyer_mode,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onPrimary,
                  ),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {
                    if (value && widget.onSwitchMode != null) {
                      widget.onSwitchMode!();
                    }
                  },
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return AppColors.success;
                    return null;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
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
          content,
        ],
      ),
    );
  }

  Widget _buildOrderStatusList(BuildContext context) {
    final s = AppLocalizations.of(context);
    final List<OrderStatusItem> items = [
      OrderStatusItem(
        icon: Icons.access_time,
        label: s.profile_pending_payment_order,
        onTap: () => _showFeatureNotImplemented(s.profile_pending_payment_order),
      ),
      OrderStatusItem(
        icon: Icons.sync,
        label: s.profile_in_progress_order,
        onTap: () => _showFeatureNotImplemented(s.profile_in_progress_order),
      ),
      OrderStatusItem(
        icon: Icons.check_circle,
        label: s.profile_completed_order,
        onTap: () => _showFeatureNotImplemented(s.profile_completed_order),
      ),
      OrderStatusItem(
        icon: Icons.undo,
        label: s.profile_refund_after_sales,
        onTap: () => _showFeatureNotImplemented(s.profile_refund_after_sales),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) => _buildOrderStatusItem(
        context,
        item.icon,
        item.label,
        item.onTap,
      )).toList(),
    );
  }

  Widget _buildOrderStatusItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, List<MenuItem> items) {
    return Column(
      children: items.map((item) => _buildMenuItem(
        context,
        item.icon,
        item.title,
        item.onTap,
      )).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
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
              color: AppColors.textTertiary,
            ),
          ],
        ),
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
          SnackBar(content: Text(AppLocalizations.of(context).profile_avatar_updated_local)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profile_image_pick_error(e.toString()))),
      );
    }
  }

  void _showFeatureNotImplemented(String featureName) {
    if (featureName == AppLocalizations.of(context).profile_my_wallet) {
      // Navigate to wallet using GoRouter
      context.push('/profile/wallet');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).profile_feature_not_implemented(featureName))),
    );
  }

  void _navigateToWallet(BuildContext context) {
    // Navigate to wallet using GoRouter
    context.push('/profile/wallet');
  }

  void _navigateToAccountSecurity(BuildContext context) {
    // Navigate to account security using GoRouter
    context.push('/profile/account-security');
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class OrderStatusItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  OrderStatusItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
