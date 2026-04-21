import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/loading_indicator.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/time_settings.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/time_management/time_management_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 卖家时间管理页面
class TimeManagementPage extends StatelessWidget {
  /// 路由名称 - This might be outdated or unused if GoRouter is primary
  static const routeName = '/seller/profile/time-management';

  /// 构造函数
  const TimeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Bloc here
    return BlocProvider<TimeManagementBloc>(
      create: (context) {
        // Use GetIt to get the instance and add the initial event
        final bloc = GetIt.I<TimeManagementBloc>();
        // Assuming LoadTimeSettings is the correct initial event based on previous code
        bloc.add(LoadTimeSettings()); 
        return bloc;
      },
      // Wrap the Scaffold with BlocProvider
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).time_management_title ?? 'Time Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              try {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/seller');
                }
              } catch (e) {
                context.go('/seller');
              }
            },
          ),
        ),
        // Use the context provided by BlocProvider
        body: const TimeManagementBody(),
      ),
      ),
    );
  }
}

/// 时间管理页面主体
class TimeManagementBody extends StatelessWidget {
  /// 构造函数
  const TimeManagementBody({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocConsumer now uses the context provided by the BlocProvider in TimeManagementPage.build
    return BlocConsumer<TimeManagementBloc, TimeManagementState>(
      listenWhen: (previous, current) =>
          (current is TimeManagementError) ||
          (previous is TimeManagementUpdating && current is TimeManagementLoaded),
      listener: (context, state) {
        if (state is TimeManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is TimeManagementLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).time_management_settings_saved ?? '设置已保存')),
          );
        }
      },
      builder: (context, state) {
        if (state is TimeManagementInitial || state is TimeManagementLoading) { // Handle Initial state
          return const Center(child: LoadingIndicator());
        }

        if (state is TimeManagementLoaded || state is TimeManagementUpdating) {
          // No change needed here, state access is correct
          final settings = state is TimeManagementLoaded 
              ? state.settings
              : (state as TimeManagementUpdating).settings;
          
          final isUpdating = state is TimeManagementUpdating;
          
          // Pass the context (which has Bloc access) down
          return _buildContent(context, settings, isUpdating);
        }

        if (state is TimeManagementError) { // Handle Error state more explicitly in builder
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(AppLocalizations.of(context).time_management_load_failed ?? 'Load Failed'),
                 const SizedBox(height: 8),
                 Text(state.message, style: const TextStyle(color: AppColors.error)),
                 const SizedBox(height: 16),
                 ElevatedButton(
                   onPressed: () => context.read<TimeManagementBloc>().add(LoadTimeSettings()),
                   child: Text(AppLocalizations.of(context).time_management_retry ?? 'Retry'),
                 )
               ],
             ),
           );
        }

        // Fallback for any other unhandled state
        return Center(child: Text(AppLocalizations.of(context).time_management_unknown_status ?? 'Unknown Status'));
      },
    );
  }

  /// 构建页面内容
  Widget _buildContent(BuildContext context, TimeSettings settings, bool isUpdating) {
    // Pass context down
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 在线状态切换
          _buildOnlineStatusSection(context, settings, isUpdating),
          
          const SizedBox(height: 24),
          
          // 状态说明
          _buildStatusDescription(context, settings.isOnline),
          
        ],
      ),
    );
  }

  /// 构建在线状态切换部分
  Widget _buildOnlineStatusSection(BuildContext context, TimeSettings settings, bool isUpdating) {
    // No changes needed here, context.read will work correctly
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).time_management_current_status ?? 'Current Status',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  settings.isOnline 
                    ? (AppLocalizations.of(context).time_management_online ?? 'Online')
                    : (AppLocalizations.of(context).time_management_offline ?? 'Offline'),
                  style: TextStyle(
                    color: settings.isOnline ? AppColors.success : AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: settings.isOnline,
                  activeThumbColor: AppColors.success,
                  onChanged: isUpdating 
                      ? null 
                      : (value) {
                          // Context here has access to the Bloc
                          context.read<TimeManagementBloc>().add(UpdateOnlineStatus(value));
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态说明部分
  Widget _buildStatusDescription(BuildContext context, bool isOnline) {
    // This widget needs context for localization
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline 
                ? (AppLocalizations.of(context).time_management_online_status_description ?? 'Online Status Description')
                : (AppLocalizations.of(context).time_management_offline_status_description ?? 'Offline Status Description'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isOnline 
                  ? (AppLocalizations.of(context).time_management_online_description ?? 'You are currently online. Buyers can send you messages and you will receive notifications for new messages. Please ensure timely responses to buyer messages as maintaining a good response rate helps improve your service quality rating.')
                  : (AppLocalizations.of(context).time_management_offline_description ?? 'You are currently offline. Buyers can still send you messages but the system will inform them that you are temporarily unavailable. You will still receive notifications for new messages but may not be able to respond immediately. Staying offline for extended periods may affect your order efficiency.'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
} 