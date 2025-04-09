import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

// --- 导入 Auth 模块 (使用相对路径) ---
import '../../presentation/pages/sms_login_page.dart';
import '../../presentation/bloc/sms_login/sms_login_cubit.dart';
import '../../domain/usecases/login_with_verification_code.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/authenticated_user_model.dart';
// --- 导入 Core 或共享的接口/实体 (使用包路径) ---
import 'package:dskk_flutter_refactor/core/platform/network_info.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import '../../domain/repositories/i_user_info_repository.dart'; // 保持在 Auth domain (临时)
import '../../domain/entities/user_info.dart'; // 保持在 Auth domain (临时)
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';

final sl = GetIt.instance; // Service Locator instance

// --- Fake Implementations ---
// (这些是模拟 Core 或 Profile 模块提供的依赖)
class FakeSecureStorageRepository implements ISecureStorageRepository {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> delete(String key) async {
    print('[FakeSecureStorage] Deleting: $key');
    _storage.remove(key);
  }
  @override
  Future<int?> getInt(String key) async {
    final value = _storage[key] as int?;
    print('[FakeSecureStorage] Getting int: $key -> $value');
    return value;
   }
  @override
  Future<String?> getString(String key) async {
    final value = _storage[key] as String?;
    print('[FakeSecureStorage] Getting string: $key -> $value');
    return value;
   }
  @override
  Future<void> saveInt(String key, int value) async {
     print('[FakeSecureStorage] Saving int: $key = $value');
    _storage[key] = value;
  }
  @override
  Future<void> saveString(String key, String value) async {
     print('[FakeSecureStorage] Saving string: $key = $value');
    _storage[key] = value;
  }
   @override
  Future<void> clearAllAuthData() async {
    print('[FakeSecureStorage] Clearing auth data (user_id, auth_token)');
    _storage.remove('user_id');
    _storage.remove('auth_token');
  }
  // 实现接口需要的其他方法 (如果ISecureStorageRepository定义了它们)
  @override
  Future<String?> getToken() async => getString('auth_token');
  @override
  Future<String?> getUserId() async => (await getInt('user_id'))?.toString();
  @override
  Future<void> saveToken(String token) => saveString('auth_token', token);
  @override
  Future<void> saveUserId(String userId) => saveInt('user_id', int.parse(userId)); // 假设存的是int
  @override
  Future<void> deleteToken() => delete('auth_token');
  @override
  Future<void> deleteUserId() => delete('user_id');
}

class FakeNetworkInfo implements NetworkInfo {
  bool _isConnected = true; // 可以修改这个值来模拟离线

  void setConnected(bool value) => _isConnected = value;

  @override
  Future<bool> get isConnected async {
    print('[FakeNetworkInfo] Checking connection -> $_isConnected');
    return _isConnected;
  }
}

class FakeUserInfoRepository implements IUserInfoRepository {
  @override
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token) async {
    print('[FakeUserInfoRepository] Fetching user info with token: $token');
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
    if (token == 'valid_token_from_login') { // 使用我们在 FakeAuthRemoteDataSource 中返回的 token
      print('[FakeUserInfoRepository] Success: Returning fake user info.');
      return const Right(UserInfo(id: 12345, mobile: '199****9999', nickName: 'Auth Preview'));
    } else {
      print('[FakeUserInfoRepository] Failure: Invalid token.');
      return Left(AuthenticationFailure(message: 'Fake: Invalid Token'));
    }
  }
}

// --- Fake Remote Data Source ---
// (模拟 API 调用)
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthenticatedUserModel> loginWithVerificationCode(credentials) async {
    print('[FakeAuthRemoteDataSource] Login attempt: phone=${credentials.phone}, code=${credentials.code}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // --- 模拟不同场景 ---
    // 1. 成功
    if (credentials.code == '123456') {
      print('[FakeAuthRemoteDataSource] Login success! Returning token.');
      return const AuthenticatedUserModel(token: 'valid_token_from_login', code: 200);
    }
    // 2. 验证码错误
    else if (credentials.code == '654321') {
       print('[FakeAuthRemoteDataSource] Login failed: Invalid code.');
       throw ServerException(message: 'Fake: Verification code is invalid');
    }
    // 3. 其他手机号/验证码组合模拟其他错误
    else {
       print('[FakeAuthRemoteDataSource] Login failed: Unknown error simulation.');
       throw ServerException(message: 'Fake: Unknown login error');
    }
  }

  @override
  Future<void> sendVerificationCode({required String phone}) async {
    print('[FakeAuthRemoteDataSource] Sending verification code to: $phone');
     await Future.delayed(const Duration(seconds: 1));
     // --- 模拟不同场景 ---
     // 1. 成功
     if(phone.endsWith('1')) { // 示例：特定手机号发送成功
        print('[FakeAuthRemoteDataSource] Code sent successfully (simulated).');
        return;
     }
     // 2. 发送失败
     else {
        print('[FakeAuthRemoteDataSource] Code sending failed (simulated).');
        throw ServerException(message: 'Fake: Failed to send verification code');
     }
  }
}

// --- Dependency Injection Setup ---
Future<void> setupLocator() async {
  print('Setting up service locator...');
  // --- Register Fakes ---
  sl.registerLazySingleton<ISecureStorageRepository>(() => FakeSecureStorageRepository());
  sl.registerLazySingleton<NetworkInfo>(() => FakeNetworkInfo());
  sl.registerLazySingleton<IUserInfoRepository>(() => FakeUserInfoRepository());
  sl.registerLazySingleton<AuthRemoteDataSource>(() => FakeAuthRemoteDataSource());

  // --- Register Real Auth Feature Classes ---
  // (Using the fakes above as their dependencies)
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        userInfoRepository: sl(),
        secureStorage: sl(),
        networkInfo: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginWithVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => SendVerificationCodeUseCase(sl()));

  // Cubits (Register as Factory because they are stateful and page-specific)
  sl.registerFactory(() => SmsLoginCubit(
        loginWithVerificationCodeUseCase: sl(),
        sendVerificationCodeUseCase: sl(),
      ));
   print('Service locator setup complete.');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); // Setup DI before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Feature Preview',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AuthPreviewHomePage(), // Start with a simple home page
    );
  }
}

// Simple Home Page for the Preview App
class AuthPreviewHomePage extends StatelessWidget {
  const AuthPreviewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Preview')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to SMS Login Page'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider<SmsLoginCubit>(
                   create: (_) => sl<SmsLoginCubit>(), // Create Cubit using GetIt for the page
                   child: const SmsLoginPage(),
                 ),
              ),
            );
          },
        ),
      ),
    );
  }
}
