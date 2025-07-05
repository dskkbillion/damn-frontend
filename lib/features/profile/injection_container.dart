import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/network/mock_network_info.dart';
import '../../core/services/image_compress_service.dart';
import 'data/datasources/profile_local_data_source.dart';
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/liked_story_repository_impl.dart';
import 'data/repositories/saved_item_repository_impl.dart';
import 'data/repositories/user_profile_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
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
    // 这里不再定义MockAuthRepository，而是使用Auth模块提供的实现
    print("IAuthRepository expected to be registered by auth module");
  }

  // Data sources - 修正构造函数参数，使用FlutterSecureStorage
  locator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: locator<Dio>(),
      storage: locator<FlutterSecureStorage>(), // 正确传递FlutterSecureStorage而不是token和userId
      imageCompressService: locator<ImageCompressService>(),
    ),
  );

  locator.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: locator()),
  );

  // Core
  if (!locator.isRegistered<NetworkInfo>()) {
    print("NetworkInfo expected to be registered by core module");
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
