import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/login_with_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/send_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/authenticated_user_model.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// Auth模块的依赖注入类
class AuthDI {
  /// 初始化Auth模块的所有依赖
  static Future<void> init(GetIt getIt) async {
    print('[AuthDI] Initializing Auth module dependencies');
    
    // 注册Cubit
    getIt.registerFactory<SmsLoginCubit>(() => SmsLoginCubit(
      sendVerificationCodeUseCase: getIt<SendVerificationCodeUseCase>(),
      loginWithVerificationCodeUseCase: getIt<LoginWithVerificationCodeUseCase>(),
    ));
    
    // 注册UseCases
    getIt.registerLazySingleton<SendVerificationCodeUseCase>(
      () => SendVerificationCodeUseCase(getIt<IAuthRepository>()),
    );
    
    getIt.registerLazySingleton<LoginWithVerificationCodeUseCase>(
      () => LoginWithVerificationCodeUseCase(getIt<IAuthRepository>()),
    );
    
    // 注册ISecureStorageRepository
    if (!getIt.isRegistered<ISecureStorageRepository>()) {
      getIt.registerLazySingleton<ISecureStorageRepository>(
        () => SecureStorageRepositoryImpl(getIt<FlutterSecureStorage>()),
      );
      print('[AuthDI] Registered ISecureStorageRepository');
    }
    
    // 注册TokenValidator
    if (!getIt.isRegistered<TokenValidator>()) {
      // 创建一个简单的TokenValidator实现，而不是使用抽象类
      getIt.registerLazySingleton<TokenValidator>(() => SimpleTokenValidator());
      print('[AuthDI] Registered TokenValidator');
    }
    
    // 注册IUserInfoRepository（需要实现）
    if (!getIt.isRegistered<IUserInfoRepository>()) {
      getIt.registerLazySingleton<IUserInfoRepository>(() => MockUserInfoRepository());
      print('[AuthDI] Registered MockUserInfoRepository');
    }
    
    // 注册AuthRepositoryImpl
    if (!getIt.isRegistered<IAuthRepository>()) {
      getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        secureStorage: getIt<ISecureStorageRepository>(),
        networkInfo: getIt<NetworkInfo>(),
        userInfoRepository: getIt<IUserInfoRepository>(),
        tokenValidator: getIt<TokenValidator>(),
      ));
      print('[AuthDI] Registered IAuthRepository');
    }
    
    // 注册真实的AuthRemoteDataSourceImpl，替换模拟实现
    if (!getIt.isRegistered<AuthRemoteDataSource>()) {
      getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
        dio: getIt<Dio>(),
      ));
      print('[AuthDI] Registered AuthRemoteDataSourceImpl');
    }
    
    print('[AuthDI] Auth module dependencies initialized');
  }
}

/// 简单的TokenValidator实现
class SimpleTokenValidator implements TokenValidator {
  @override
  Future<TokenValidationResult> validateToken(String token) async {
    // 简单实现，始终返回有效
    return TokenValidationResult.valid;
  }
}

/// 模拟的UserInfoRepository实现
class MockUserInfoRepository implements IUserInfoRepository {
  @override
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token) async {
    // 模拟获取用户信息
    print('[MockUserInfoRepository] Fetching user info with token: $token');
    await Future.delayed(const Duration(seconds: 1));
    
    // 返回成功结果
    return Right(const UserInfo(
      id: 12345,
      mobile: '13800138000',
      nickName: 'MockUser',
      avatar: 'https://example.com/avatar.jpg',
      commonUserId: 67890,
    ));
  }
} 