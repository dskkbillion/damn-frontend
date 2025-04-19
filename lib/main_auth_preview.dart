import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/platform/network_info.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/auth/data/models/authenticated_user_model.dart';
import 'package:dskk_flutter_refactor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user_info.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_info_repository.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/login_with_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/usecases/send_verification_code.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/pages/sms_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart'; // Import TokenValidator and related enum

final sl = GetIt.instance; // Service Locator instance for preview

// --- Fake Implementations ---

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
  Future<String?> getToken() => getString('auth_token');
  @override
  Future<String?> getUserId() async => (await getInt('user_id'))?.toString();
  @override
  Future<void> saveToken(String token) => saveString('auth_token', token);
  @override
  Future<void> saveUserId(String userId) async => saveInt('user_id', int.parse(userId));
  @override
  Future<void> deleteToken() => delete('auth_token');
  @override
  Future<void> deleteUserId() => delete('user_id');
  @override
  Future<void> clearAllAuthData() async {
    await deleteToken();
    await deleteUserId();
    await deleteCommonUserId(); // Also clear common user id
  }

  // --- Corrected fake implementations for common_user_id (int) ---
  @override
  Future<int?> getCommonUserId() async {
     // Read as String from storage, then parse to int
     final valueString = _storage['common_user_id'] as String?;
     print('[FakeSecureStorage] Getting string: common_user_id -> $valueString');
     if (valueString != null) {
         return int.tryParse(valueString);
     }
     return null;
  }

  @override
  Future<void> saveCommonUserId(int commonUserId) async {
    // Store as String in the fake storage
    final valueString = commonUserId.toString();
    print('[FakeSecureStorage] Saving string: common_user_id = $valueString');
    _storage['common_user_id'] = valueString;
  }

  @override
  Future<void> deleteCommonUserId() async {
    print('[FakeSecureStorage] Deleting: common_user_id');
    _storage.remove('common_user_id');
  }
  // -----------------------------------------------------------
}

class FakeNetworkInfo implements NetworkInfo {
  bool _isConnected = true; // Default to connected
  void setConnected(bool value) => _isConnected = value;
  @override
  Future<bool> get isConnected async => _isConnected;
}

class FakeUserInfoRepository implements IUserInfoRepository {
  // Simulate fetching user info after successful login
  @override
  Future<Either<Failure, UserInfo>> fetchUserInfo(String token) async {
    print('[FakeUserInfoRepo] Fetching user info with token: $token');
    await Future.delayed(const Duration(milliseconds: 100));
    if (token == 'fake_valid_token') {
      // Return dummy user info if the token matches the one from fake login
      return const Right(UserInfo(id: 999, mobile: '138****1234', nickName: 'Auth Preview User'));
    } else {
      return Left(AuthenticationFailure(message: 'Fake: Invalid token provided to fetchUserInfo'));
    }
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  // Simulate sending verification code
  @override
  Future<void> sendVerificationCode({required String phone}) async {
    print('[FakeAuthRemote] Attempting to send code to: $phone');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // Simulate success, maybe add logic later to simulate failures based on phone#
    if (phone.startsWith('1')) { // Basic check
        print('[FakeAuthRemote] Code sent successfully (simulated).');
        return;
    } else {
        print('[FakeAuthRemote] Code sending failed (simulated invalid phone).');
        throw ServerException(message: 'Fake: Invalid phone number format');
    }
  }

  // Simulate login with verification code
  @override
  Future<AuthenticatedUserModel> loginWithVerificationCode(VerificationCodeCredentials credentials) async {
     print('[FakeAuthRemote] Attempting login with phone: ${credentials.phone}, code: ${credentials.code}');
     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
     // Simulate success if code is "1234" or "123456", otherwise fail
     if (credentials.code == '1234' || credentials.code == '123456') {
       print('[FakeAuthRemote] Login successful (simulated). Returning fake token.');
       return const AuthenticatedUserModel(token: 'fake_valid_token');
     } else {
       print('[FakeAuthRemote] Login failed (simulated wrong code).');
       throw ServerException(message: 'Fake: Invalid verification code');
     }
  }
}

// --- Fake Token Validator (Corrected) --- 
// Now implements the actual TokenValidator interface
class FakeTokenValidator implements TokenValidator {
   // Correct return type and return value
   @override
   Future<TokenValidationResult> validateToken(String token) async {
      print('[FakeTokenValidator] Validating token: $token -> always returning valid');
      return TokenValidationResult.valid; // Return the enum value
   }
}

// --- Dependency Injection Setup for Preview ---

Future<void> configureAuthPreviewDependencies() async {
  print('Setting up dependencies for Auth Preview...');

  // Register Fakes
  sl.registerLazySingleton<ISecureStorageRepository>(() => FakeSecureStorageRepository());
  sl.registerLazySingleton<NetworkInfo>(() => FakeNetworkInfo());
  sl.registerLazySingleton<IUserInfoRepository>(() => FakeUserInfoRepository());
  sl.registerLazySingleton<AuthRemoteDataSource>(() => FakeAuthRemoteDataSource());
  // Register the fake validator using the INTERFACE type
  sl.registerLazySingleton<TokenValidator>(() => FakeTokenValidator()); 

  // Register Real Auth Domain & Data Layer (wired to fakes)
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        secureStorage: sl(),
        networkInfo: sl(),
        userInfoRepository: sl(),
        // Provide an instance of the TokenValidator (which will be the Fake one)
        tokenValidator: sl<TokenValidator>(), 
      ));

  // Register Real Use Cases (wired to real repository)
  sl.registerLazySingleton(() => SendVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithVerificationCodeUseCase(sl()));

  // Register Real Cubit (as factory, wired to real use cases)
  sl.registerFactory(() => SmsLoginCubit(
        sendVerificationCodeUseCase: sl(),
        loginWithVerificationCodeUseCase: sl(),
      ));

  print('Auth Preview dependencies setup complete.');
}

// --- Main Entry Point for Preview ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAuthPreviewDependencies(); // Use the dedicated DI setup
  runApp(const AuthPreviewApp());
}

// --- Root Widget for Preview ---

class AuthPreviewApp extends StatelessWidget {
  const AuthPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple MaterialApp, directly showing the SmsLoginPage with its Cubit
    return MaterialApp(
      title: 'Auth Feature Preview',
      debugShowCheckedModeBanner: false, // Hide debug banner for preview
      theme: ThemeData(
         // Use a simple theme, maybe copy relevant colors from main app later
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB66D0E)), // Use your primary color
        useMaterial3: true,
      ),
      home: BlocProvider<SmsLoginCubit>(
        create: (_) => sl<SmsLoginCubit>(), // Create Cubit using GetIt
        child: const SmsLoginPage(), // Directly show the login page
      ),
      // Optional: Add a listener for auth status changes *within the preview*
      // home: BlocListener<AuthStatusCubit, AuthStatus>( // Assuming you have an AuthStatusCubit registered
      //   listener: (context, state) {
      //       print("Preview Auth Status Changed: $state");
      //       // You could show Snackbars here on success/failure
      //   },
      //   child: BlocProvider<SmsLoginCubit>(
      //     create: (_) => sl<SmsLoginCubit>(),
      //     child: const SmsLoginPage(),
      //   ),
      // ),
    );
  }
}
