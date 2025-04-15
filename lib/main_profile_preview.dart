import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'core/network/network_info.dart';
import 'core/error/failures.dart';
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/models/user_profile_dto.dart';
import 'features/profile/data/models/wallet_summary_dto.dart';
import 'features/profile/data/models/saved_item_dto.dart';
import 'features/profile/data/models/liked_story_dto.dart';
import 'features/profile/data/repositories/user_profile_repository_impl.dart';
import 'features/profile/domain/repositories/i_auth_repository.dart';
import 'features/profile/domain/repositories/i_user_profile_repository.dart';
import 'features/profile/domain/usecases/get_user_profile.dart';
import 'features/profile/domain/usecases/update_user_profile.dart';
import 'features/profile/domain/usecases/logout.dart';
import 'features/profile/domain/usecases/upload_avatar.dart';
import 'features/profile/domain/usecases/get_wallet_summary.dart';
import 'features/profile/domain/usecases/check_auth_status.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/presentation/pages/bloc_profile_page.dart';
import 'features/profile/domain/repositories/i_wallet_repository.dart';
import 'features/profile/data/repositories/wallet_repository_impl.dart';
import 'core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

// 使用 GetIt 单例进行依赖注入
final GetIt sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置依赖
  await _setupDependencies();

  runApp(const ProfilePreviewApp());
}

Future<void> _setupDependencies() async {
  // 注册外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  // 只在非Web平台注册InternetConnectionChecker
  if (!kIsWeb) {
    sl.registerLazySingleton(() => InternetConnectionChecker());
  }

  // 根据平台注册不同的NetworkInfo实现
  if (kIsWeb) {
    sl.registerLazySingleton<NetworkInfo>(() => WebNetworkInfoImpl());
  } else {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  }

  // 注册数据源
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // 使用模拟数据源进行预览
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => MockProfileRemoteDataSource(),
  );

  // 注册认证仓库的模拟实现
  sl.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(),
  );

  // 注册仓库
  sl.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 注册钱包仓库
  sl.registerLazySingleton<IWalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 注册用例
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletSummary(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // 注册BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      logout: sl(),
      updateUserProfile: sl(),
      uploadAvatar: sl(),
      getWalletSummary: sl(),
      checkAuthStatus: sl(),
    ),
  );

  sl.registerFactory(
    () => WalletBloc(
      getWalletSummary: sl(),
    ),
  );
}

class ProfilePreviewApp extends StatelessWidget {
  const ProfilePreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '个人中心预览',
      theme: ThemeData(
        // 定义主题色为#b66d0e
        primarySwatch: MaterialColor(0xFFB66D0E, {
          50: const Color(0xFFF9ECCF),
          100: const Color(0xFFF0D9A0),
          200: const Color(0xFFE6C571),
          300: const Color(0xFFDCB141),
          400: const Color(0xFFCEA128),
          500: const Color(0xFFB66D0E), // 主色
          600: const Color(0xFFA85F0D),
          700: const Color(0xFF9A510B),
          800: const Color(0xFF8C430A),
          900: const Color(0xFF753506),
        }),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB66D0E),
          secondary: Color(0xFFB66D0E),
          onPrimary: Colors.white,
        ),
        primaryColor: const Color(0xFFB66D0E),
        primaryColorLight: const Color(0xFFE6C571),
        primaryColorDark: const Color(0xFF8C430A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFFB66D0E)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFB66D0E);
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFFE6C571);
            }
            return Colors.grey.withOpacity(0.5);
          }),
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => sl<ProfileBloc>()),
          BlocProvider(create: (context) => sl<WalletBloc>()),
        ],
        child: const BlocProfilePage(),
      ),
    );
  }
}

// 模拟远程数据源实现
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<String> uploadAvatar(File imageFile) async {
    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 2));
    // 返回一个应用内部资源路径而不是外部URL
    return "assets/images/avatar_placeholder.png";
  }

  @override
  Future<UserProfileDto> getUserProfile() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 返回模拟数据，使用应用内部资源路径
    return const UserProfileDto(
      userId: '1',
      nickName: '测试用户',
      avatarUrl: 'assets/images/avatar_placeholder.png',
      onlineFlag: true,
    );
  }

  @override
  Future<UserProfileDto> updateUserProfile(UserProfileUpdateData data) async {
    // 模拟更新延迟
    await Future.delayed(const Duration(seconds: 1));

    return UserProfileDto(
      userId: '1',
      nickName: data.nickName ?? '测试用户',
      avatarUrl: 'assets/images/avatar_placeholder.png',
      onlineFlag: data.onlineFlag ?? true,
    );
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return const WalletSummaryDto(
      balance: 1000.0,
      pendingAmount: 200.0,
      totalIncome: 5000.0,
    );
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    required int page,
    required int pageSize,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return []; // 返回空列表作为模拟数据
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    required int page,
    required int pageSize,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return []; // 返回空列表作为模拟数据
  }
}

// 模拟认证仓库实现
class MockAuthRepository implements IAuthRepository {
  bool _isAuthenticated = true;

  @override
  Future<bool> checkAuthStatus() async {
    return isLoggedIn();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = false;
    return const Right(null);
  }

  @override
  Future<String?> getCurrentUserId() async {
    if (_isAuthenticated) {
      return '1';
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _isAuthenticated;
  }
}
