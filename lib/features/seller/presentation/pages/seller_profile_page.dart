import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// 导入国际化
import '../../../../generated/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../../app/app_mode.dart';
import '../../../../core/services/mode_transition_service.dart';

class SellerProfilePage extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToBuyer;

  const SellerProfilePage({Key? key, this.onSwitchToBuyer}) : super(key: key);

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  // 卖家模式开关
  bool _sellerModeOn = true;

  @override
  void initState() {
    super.initState();
    AppLogger.d('[SellerProfilePage] initState called');
  }

  @override
  void dispose() {
    AppLogger.d('[SellerProfilePage] dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[SellerProfilePage] build called');
    // 使用BlocProvider.value来使用现有的单例BLoC实例
    final profileBloc = GetIt.instance<ProfileBloc>();
    
    // 检查当前状态，避免重复初始化
    final currentState = profileBloc.state;
    AppLogger.d('[SellerProfilePage] Current ProfileBloc state: ${currentState.runtimeType}');
    
    // 只在真正需要时才触发初始化
    if (currentState is ProfileInitial) {
      AppLogger.d('[SellerProfilePage] ProfileBloc is in Initial state, triggering CheckAuthStatus');
      profileBloc.add(CheckAuthStatusEvent());
    } else if (currentState is ProfileLoaded || currentState is ProfileUpdated) {
      AppLogger.d('[SellerProfilePage] Profile already loaded: ${(currentState as dynamic).profile?.nickName}');
      // 已经有数据了，不需要重新加载
    }
    
    return BlocProvider.value(
      value: profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileAuthStatusLoaded && state.isAuthenticated) {
            // 认证成功后，使用缓存优先的方式获取数据
            context.read<ProfileBloc>().add(GetUserProfileCachedEvent(mode: AppMode.seller));
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 处理初始状态和认证检查状态
            if (state is ProfileInitial || 
                (state is ProfileAuthStatusLoaded && !state.isAuthenticated)) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // 对于其他状态，包括ProfileLoading，继续显示UI
            // 这样可以避免页面闪烁
            
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    _buildProfileHeader(state),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildOrderSection(),
                            _buildMenuSection(AppLocalizations.of(context)!.seller_profile_auth_management, Icons.verified_user, ''),
                            _buildMenuSection(AppLocalizations.of(context)!.seller_profile_my_wallet, Icons.account_balance_wallet_outlined, ''),
                            _buildMenuSection(AppLocalizations.of(context)!.seller_profile_time_management, Icons.access_time_outlined, ''),
                            const SizedBox(height: 10),
                            _buildSectionTitle(AppLocalizations.of(context)!.seller_profile_settings),
                            _buildMenuSection(
                              AppLocalizations.of(context)!.seller_profile_notifications, 
                              Icons.notifications_none_outlined, 
                              '',
                              onTap: () {
                                // 导航到通知列表页面
                                context.push('/seller/notifications');
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildSectionTitle(AppLocalizations.of(context)!.seller_profile_about_us),
                            _buildMenuSection(AppLocalizations.of(context)!.seller_profile_mission, Icons.emoji_objects_outlined, ''),
                          ],
                        ),
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

  Widget _buildProfileHeader(ProfileState state) {
    UserProfile? profile;
    if (state is ProfileLoaded) {
      profile = state.profile;
    } else if (state is ProfileUpdated) {
      profile = state.profile;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFB66D0E), // 原型中使用的卖家模式主色调
      child: Column(
        children: [
          // 用户信息
          Row(
            children: [
              // 头像 - 点击跳转到店铺页面
              GestureDetector(
                onTap: () {
                  AppLogger.d('[SellerProfilePage] Avatar tapped, profile: $profile');
                  AppLogger.d('[SellerProfilePage] userId: ${profile?.userId}');
                  if (profile?.userId != null) {
                    final route = '/seller-profile/${profile!.userId}';
                    AppLogger.d('[SellerProfilePage] Navigating to: $route');
                    context.go(route);
                  } else {
                    AppLogger.d('[SellerProfilePage] Cannot navigate: userId is null');
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.nickName ?? AppLocalizations.of(context)!.seller_profile_user_name,  // 用户名
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.seller_profile_seller_mode_online,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 卖家模式开关
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sellerModeOn ? AppLocalizations.of(context)!.seller_profile_seller_mode : AppLocalizations.of(context)!.seller_profile_buyer_mode,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 如果当前是卖家模式，点击即切换到买家模式
                    if (_sellerModeOn && widget.onSwitchToBuyer != null) {
                      widget.onSwitchToBuyer!();
                    } else {
                      // 其他情况正常切换状态
                      setState(() {
                        _sellerModeOn = !_sellerModeOn;
                      });
                    }
                  },
                  child: Switch(
                    value: _sellerModeOn,
                    onChanged: null, // 禁用Switch的自动状态变化
                    activeColor: const Color(0xFFB66D0E),
                    activeTrackColor: const Color(0xFFB66D0E).withOpacity(0.5),
                    // 保持Switch可交互的视觉样式
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
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
            AppLocalizations.of(context)!.seller_profile_my_orders,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(Icons.attach_money, AppLocalizations.of(context)!.seller_profile_order_pending, 0),
              _buildOrderStatusItem(Icons.sync, AppLocalizations.of(context)!.seller_profile_order_processing, 0),
              _buildOrderStatusItem(Icons.check_circle_outline, AppLocalizations.of(context)!.seller_profile_order_delivered, 0),
              _buildOrderStatusItem(Icons.assignment_return_outlined, AppLocalizations.of(context)!.seller_profile_order_refund, 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(IconData icon, String label, int count) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF333333),
              ),
            ),
            if (count > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, IconData icon, String badge, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF666666),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF333333),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge.isNotEmpty)
              Text(
                badge,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        onTap: onTap ?? () {
          _showNotImplemented(title);
        },
      ),
    );
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.seller_profile_feature_not_implemented(feature))),
    );
  }
}
