import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/network/mock_network_info.dart';
import 'data/datasources/profile_local_data_source.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/liked_story_repository_impl.dart';
import 'data/repositories/saved_item_repository_impl.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_liked_story_repository.dart';
import 'domain/repositories/i_saved_item_repository.dart';
import 'domain/repositories/i_user_profile_repository.dart';
import 'domain/repositories/i_wallet_repository.dart';
import 'domain/usecases/check_auth_status.dart';
import 'domain/usecases/get_liked_stories.dart';
import 'domain/usecases/get_saved_items.dart';
import 'domain/usecases/get_user_profile.dart';
import 'domain/usecases/get_wallet_summary.dart';
import 'domain/usecases/get_wallet_transactions.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/update_user_profile.dart';
import 'domain/usecases/upload_avatar.dart';
import 'presentation/bloc/profile_bloc.dart';
import 'presentation/bloc/wallet_bloc.dart';

/// 依赖注入容器，注册 Profile 模块相关的服务
Future<void> initProfileDependencies(GetIt locator) async {
  // Bloc
  locator.registerFactory(
    () => ProfileBloc(
      getUserProfile: locator(),
      updateUserProfile: locator(),
      uploadAvatar: locator(),
      getWalletSummary: locator(),
      checkAuthStatus: locator(),
      logout: locator(),
    ),
  );

  locator.registerFactory(
    () => WalletBloc(
      getWalletSummary: locator(),
      getWalletTransactions: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => GetUserProfileUseCase(locator()));
  locator.registerLazySingleton(() => UpdateUserProfileUseCase(locator()));
  locator.registerLazySingleton(() => UploadAvatarUseCase(locator()));
  locator.registerLazySingleton(() => GetWalletSummary(locator()));
  locator.registerLazySingleton(() => GetWalletTransactions(locator()));
  locator.registerLazySingleton(() => GetSavedItemsUseCase(locator()));
  locator.registerLazySingleton(() => GetLikedStoriesUseCase(locator()));
  locator.registerLazySingleton(() => CheckAuthStatusUseCase(locator()));
  locator.registerLazySingleton(() => LogoutUseCase(locator()));

  // Repositories
  locator.registerLazySingleton<IUserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: locator(),
      localDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  locator.registerLazySingleton<IWalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  locator.registerLazySingleton<ISavedItemRepository>(
    () => SavedItemRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  locator.registerLazySingleton<ILikedStoryRepository>(
    () => LikedStoryRepositoryImpl(
      remoteDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  // 注册 AuthRepository (假设这是由 Auth 模块提供的)
  // 这里只是做一个检查，如果 Auth 模块已经注册了这个服务，就不再重复注册
  if (!locator.isRegistered<IAuthRepository>()) {
    // 在集成阶段，应该移除这部分代码，并依赖 Auth 模块提供的实现
    locator.registerLazySingleton<IAuthRepository>(() => MockAuthRepository());
  }

  // Data sources
  locator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: locator<Dio>(),
      token: '用户给定的token', // 这里应该使用用户之前提供的token
      userId: '用户ID', // 这里应该使用用户之前提供的userID
    ),
  );

  locator.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: locator()),
  );

  // Core
  if (!locator.isRegistered<NetworkInfo>()) {
    locator.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(locator()),
    );
  }

  // External
  if (!locator.isRegistered<InternetConnectionChecker>()) {
    locator.registerLazySingleton(() => InternetConnectionChecker());
  }

  if (!locator.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    locator.registerLazySingleton(() => sharedPreferences);
  }

  if (!locator.isRegistered<Dio>()) {
    locator.registerLazySingleton(() => Dio());
  }
}

/// Auth 模块的 Mock 实现，仅用于预览/测试
class MockAuthRepository implements IAuthRepository {
  bool _isLoggedIn = true;

  @override
  Future<String?> getCurrentUserId() async {
    return _isLoggedIn ? 'mock_user_id' : null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  @override
  Future<Either<Failure, void>> logout() async {
    _isLoggedIn = false;
    return Right(null);
  }
}
