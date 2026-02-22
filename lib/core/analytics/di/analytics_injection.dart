import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

import '../analytics_manager.dart';
import '../services/analytics_api_service.dart';
import '../services/device_info_service.dart';
import '../services/user_identification_service.dart';
import '../services/event_buffer.dart';
import '../../auth/repositories/i_auth_repository.dart' as core_auth;

/// 初始化分析模块
/// 在应用启动时调用
Future<void> initAnalyticsModule() async {
  final getIt = GetIt.instance;
  
  // 确保SharedPreferences已初始化
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }
  
  // 确保Dio已初始化
  if (!getIt.isRegistered<Dio>()) {
    final dio = Dio();
    getIt.registerSingleton<Dio>(dio);
  }
  
  // 手动注册所有分析模块依赖
  
  // 1. 注册API服务
  if (!getIt.isRegistered<AnalyticsApiService>()) {
    getIt.registerSingleton<AnalyticsApiService>(
      AnalyticsApiService(getIt<Dio>())
    );
  }
  
  // 2. 注册设备信息服务
  if (!getIt.isRegistered<DeviceInfoService>()) {
    getIt.registerSingleton<DeviceInfoService>(
      DeviceInfoService()
    );
  }
  
  // 检查是否需要创建一个适配器，将features/auth中的IAuthRepository转换为core/auth中的IAuthRepository
  try {
    if (!getIt.isRegistered<core_auth.IAuthRepository>()) {
      AppLogger.d('[AnalyticsModule] 创建IAuthRepository适配器...');
      // 创建一个适配器，使用features/auth中的IAuthRepository来实现core/auth中的IAuthRepository
      getIt.registerSingleton<core_auth.IAuthRepository>(
        AuthRepositoryAdapter()
      );
    }
  } catch (e) {
    AppLogger.d('[AnalyticsModule] 创建IAuthRepository适配器失败: $e');
  }
  
  // 3. 注册用户识别服务
  if (!getIt.isRegistered<UserIdentificationService>()) {
    getIt.registerSingleton<UserIdentificationService>(
      UserIdentificationService(
        getIt<core_auth.IAuthRepository>(),
        getIt<DeviceInfoService>(),
        getIt<SharedPreferences>(),
      )
    );
  }
  
  // 4. 注册事件缓存服务
  if (!getIt.isRegistered<EventBuffer>()) {
    getIt.registerSingleton<EventBuffer>(
      EventBuffer(
        getIt<AnalyticsApiService>(),
        getIt<SharedPreferences>(),
      )
    );
  }
  
  // 5. 注册分析管理器 - 最重要的部分
  if (!getIt.isRegistered<AnalyticsManager>()) {
    getIt.registerSingleton<AnalyticsManager>(
      AnalyticsManager(
        getIt<AnalyticsApiService>(),
        getIt<DeviceInfoService>(),
        getIt<UserIdentificationService>(),
        getIt<EventBuffer>(),
      )
    );
  }
  
  AppLogger.d('[AnalyticsModule] 分析模块初始化完成');
}

/// 适配器类，用于将features/auth中的IAuthRepository转换为core/auth中的IAuthRepository
class AuthRepositoryAdapter implements core_auth.IAuthRepository {
  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      // 尝试从FlutterSecureStorage获取用户ID
      final secureStorage = GetIt.instance<FlutterSecureStorage>();
      final userId = await secureStorage.read(key: 'user_id');
      
      if (userId != null && userId.isNotEmpty) {
        return Right(userId);
      } else {
        return Left(AnalyticsAuthFailure());
      }
    } catch (e) {
      AppLogger.d('[AuthRepositoryAdapter] 获取用户ID失败: $e');
      return Left(AnalyticsAuthFailure(message: e.toString()));
    }
  }
}

/// 分析模块的认证失败类
class AnalyticsAuthFailure extends AuthFailure {
  const AnalyticsAuthFailure({String message = '用户未认证'}) : super(message: message);
} 