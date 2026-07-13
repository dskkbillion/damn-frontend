import 'dart:async';

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
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_time_settings_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

class SellerProfilePage extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToBuyer;

  const SellerProfilePage({super.key, this.onSwitchToBuyer});

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  // 卖家模式开关
  bool _sellerModeOn = true;

  // 卖家在线状态（默认在线，从API加载后更新）
  bool _isOnline = true;

  // 事件总线订阅
  StreamSubscription<SellerOnlineStatusChangedEvent>? _onlineStatusSubscription;

  @override
  void initState() {
    super.initState();
    AppLogger.d('[SellerProfilePage] initState called');

    // 从API加载初始在线状态
    _loadOnlineStatus();

    // 监听在线状态变更事件（来自时间管理页面的切换）
    _onlineStatusSubscription = EventBus().sellerOnlineStatusChangedStream.listen((event) {
      if (mounted) {
        setState(() {
          _isOnline = event.isOnline;
        });
        AppLogger.d('[SellerProfilePage] Online status updated via EventBus: ${event.isOnline}');
      }
    });
  }

  /// 从API加载卖家的初始在线状态
  Future<void> _loadOnlineStatus() async {
    try {
      final getTimeSettingsUseCase = GetIt.instance<GetTimeSettingsUseCase>();
      final result = await getTimeSettingsUseCase(NoParams());
      result.fold(
        (failure) {
          AppLogger.d('[SellerProfilePage] Failed to load online status: ${failure.message}');
        },
        (settings) {
          if (mounted) {
            setState(() {
              _isOnline = settings.isOnline;
            });
            AppLogger.d('[SellerProfilePage] Initial online status loaded: ${settings.isOnline}');
          }
        },
      );
    } catch (e) {
      AppLogger.d('[SellerProfilePage] Error loading online status: $e');
    }
  }

  @override
  void dispose() {
    AppLogger.d('[SellerProfilePage] dispose called');
    _onlineStatusSubscription?.cancel();
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
            context.read<ProfileBloc>().add(const GetUserProfileCachedEvent(mode: AppMode.seller));
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 处理初始状态和认证检查状态
            if (state is ProfileInitial ||
                (state is ProfileAuthStatusLoaded && !state.isAuthenticated)) {
              return const Scaffold(
                backgroundColor: Colors.transparent,
                body: GlassBackdrop(
                  child: SafeArea(child: SkeletonPage(itemCount: 4)),
                ),
              );
            }
            
            // 对于其他状态，包括ProfileLoading，继续显示UI
            // 这样可以避免页面闪烁
            
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: GlassBackdrop(
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildProfileHeader(state),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: GlassNavigationMetrics.contentBottomInset(context) +
                                AppDimensions.spacingXl,
                          ),
                          child: Column(
                            children: [
                            _buildOrderSection(),
                            // TODO(#306): 认证功能暂未完善，隐藏入口
                            // _buildMenuSection(AppLocalizations.of(context)!.seller_profile_auth_management, Icons.verified_user, ''),
                            _buildMenuSection(AppLocalizations.of(context).seller_profile_my_wallet, Icons.account_balance_wallet_outlined, '',
                              onTap: () => context.push('/seller/wallet'),
                            ),
                            _buildMenuSection('收款账户', Icons.account_balance_outlined, '',
                              onTap: () => context.push('/seller/connect-account'),
                            ),
                            _buildMenuSection(AppLocalizations.of(context).seller_profile_time_management, Icons.access_time_outlined, '',
                              onTap: () => context.push(SellerRoutes.timeManagement),
                            ),
                            const SizedBox(height: 10),
                            _buildSectionTitle(AppLocalizations.of(context).seller_profile_settings),
                            _buildMenuSection(
                              AppLocalizations.of(context).seller_profile_notifications, 
                              Icons.notifications_none_outlined, 
                              '',
                              onTap: () {
                                // 导航到通知列表页面
                                context.push('/seller/notifications');
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildSectionTitle(AppLocalizations.of(context).seller_profile_about_us),
                            _buildMenuSection(AppLocalizations.of(context).seller_profile_mission, Icons.emoji_objects_outlined, ''),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
    return GlassCard(
      margin: const EdgeInsets.all(AppDimensions.spacingLg),
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      tintColor: Theme.of(context).colorScheme.primary,
      tintOpacity: 0.76,
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
                    context.push(route);
                  } else {
                    AppLogger.d('[SellerProfilePage] Cannot navigate: userId is null');
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: const Border.fromBorderSide(
                      BorderSide(color: AppColors.onPrimary, width: AppDimensions.borderThick),
                    ),
                  ),
                  child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: profile.avatarUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.onPrimary,
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
                      profile?.nickName ?? AppLocalizations.of(context).seller_profile_user_name,  // 用户名
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _isOnline ? AppColors.success : AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isOnline
                                ? AppLocalizations.of(context).seller_profile_seller_mode_online
                                : AppLocalizations.of(context).seller_profile_seller_mode_offline,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 卖家模式开关
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sellerModeOn ? AppLocalizations.of(context).seller_profile_seller_mode : AppLocalizations.of(context).seller_profile_buyer_mode,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return Theme.of(context).colorScheme.primary;
                      return AppColors.textTertiary;
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                      return AppColors.borderInput;
                    }),
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
    return GlassCard(
      margin: const EdgeInsets.all(AppDimensions.spacingLg),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).seller_profile_my_orders,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(Icons.attach_money, AppLocalizations.of(context).seller_profile_order_pending, 0),
              _buildOrderStatusItem(Icons.sync, AppLocalizations.of(context).seller_profile_order_processing, 0),
              _buildOrderStatusItem(Icons.check_circle_outline, AppLocalizations.of(context).seller_profile_order_delivered, 0),
              _buildOrderStatusItem(Icons.assignment_return_outlined, AppLocalizations.of(context).seller_profile_order_refund, 0),
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
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
              ),
            ),
            if (count > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingXs),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: AppColors.onPrimary,
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
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, IconData icon, String badge, {VoidCallback? onTap}) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: 4),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge.isNotEmpty)
              Text(
                badge,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 5),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textTertiary,
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
      SnackBar(content: Text(AppLocalizations.of(context).seller_profile_feature_not_implemented(feature))),
    );
  }
}
