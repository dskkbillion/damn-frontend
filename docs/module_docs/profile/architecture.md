# Profile模块架构设计

本文档详细说明Profile模块的架构设计，遵循Clean Architecture原则，分为三个主要层次：Domain（领域层）、Data（数据层）和Presentation（表现层）。

## 总体架构

Profile模块采用Clean Architecture架构，主要分为以下三层：

1. **Domain层**：包含核心业务逻辑，定义实体、仓库接口和用例。
2. **Data层**：负责数据获取和存储，实现Domain层定义的仓库接口。
3. **Presentation层**：负责UI展示和用户交互，使用BLoC模式管理状态。

## Domain层（领域层）

### 实体（Entities）

1. **UserProfile**：用户资料实体
   ```dart
   class UserProfile extends Equatable {
     final String id;
     final String username;
     final String nickname;
     final String? avatarUrl;
     final String? phone;
     final String? email;
     final int gender;
     final String? birthday;
     final String? bio;
     final bool isSellerMode;
     final DateTime createdAt;
     final DateTime updatedAt;

     // 构造函数、equals方法等
   }
   ```

2. **WalletSummary**：钱包摘要实体
   ```dart
   class WalletSummary extends Equatable {
     final double balance;
     final double frozenAmount;
     final DateTime lastUpdated;

     // 构造函数、equals方法等
   }
   ```

### 仓库接口（Repository Interfaces）

1. **IProfileRepository**：用户资料仓库接口
   ```dart
   abstract class IProfileRepository {
     Future<Either<Failure, UserProfile>> getUserProfile();
     Future<Either<Failure, UserProfile>> updateUserProfile({String? nickname, bool? onlineFlag});
     Future<Either<Failure, String>> uploadAvatar(File imageFile);
     Future<Either<Failure, bool>> switchUserMode(bool isSellerMode);
   }
   ```

2. **IWalletRepository**：钱包仓库接口
   ```dart
   abstract class IWalletRepository {
     Future<Either<Failure, WalletSummary>> getWalletSummary();
   }
   ```

### 用例（Use Cases）

1. **GetUserProfileUseCase**：获取用户资料用例
   ```dart
   class GetUserProfileUseCase {
     final IProfileRepository repository;

     GetUserProfileUseCase(this.repository);

     Future<Either<Failure, UserProfile>> call() async {
       return await repository.getUserProfile();
     }
   }
   ```

2. **UpdateUserProfileUseCase**：更新用户资料用例
   ```dart
   class UpdateUserProfileUseCase {
     final IProfileRepository repository;

     UpdateUserProfileUseCase(this.repository);

     Future<Either<Failure, UserProfile>> call({String? nickname, bool? onlineFlag}) async {
       return await repository.updateUserProfile(nickname: nickname, onlineFlag: onlineFlag);
     }
   }
   ```

3. **UploadAvatarUseCase**：上传头像用例
   ```dart
   class UploadAvatarUseCase {
     final IProfileRepository repository;

     UploadAvatarUseCase(this.repository);

     Future<Either<Failure, String>> call(File imageFile) async {
       return await repository.uploadAvatar(imageFile);
     }
   }
   ```

4. **GetWalletSummaryUseCase**：获取钱包摘要用例
   ```dart
   class GetWalletSummaryUseCase {
     final IWalletRepository repository;

     GetWalletSummaryUseCase(this.repository);

     Future<Either<Failure, WalletSummary>> call() async {
       return await repository.getWalletSummary();
     }
   }
   ```

5. **SwitchUserModeUseCase**：切换用户模式用例
   ```dart
   class SwitchUserModeUseCase {
     final IProfileRepository repository;

     SwitchUserModeUseCase(this.repository);

     Future<Either<Failure, bool>> call(bool isSellerMode) async {
       return await repository.switchUserMode(isSellerMode);
     }
   }
   ```

## Data层（数据层）

### 数据模型（Models）

1. **UserProfileModel**：用户资料数据模型
   ```dart
   class UserProfileModel extends UserProfile {
     // 构造函数
     // fromJson和toJson方法
   }
   ```

2. **WalletSummaryModel**：钱包摘要数据模型
   ```dart
   class WalletSummaryModel extends WalletSummary {
     // 构造函数
     // fromJson和toJson方法
   }
   ```

### 数据源（Data Sources）

1. **ProfileRemoteDataSource**：用户资料远程数据源
   ```dart
   abstract class ProfileRemoteDataSource {
     Future<UserProfileModel> getUserProfile();
     Future<UserProfileModel> updateUserProfile({String? nickname, bool? onlineFlag});
     Future<String> uploadAvatar(File imageFile);
     Future<bool> switchUserMode(bool isSellerMode);
   }

   class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
     final DioClient dioClient;

     ProfileRemoteDataSourceImpl({required this.dioClient});

     // 方法实现
   }
   ```

2. **ProfileLocalDataSource**：用户资料本地数据源
   ```dart
   abstract class ProfileLocalDataSource {
     Future<UserProfileModel?> getCachedUserProfile();
     Future<void> cacheUserProfile(UserProfileModel userProfile);
   }

   class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
     final SharedPreferences sharedPreferences;

     ProfileLocalDataSourceImpl({required this.sharedPreferences});

     // 方法实现
   }
   ```

3. **WalletRemoteDataSource**：钱包远程数据源
   ```dart
   abstract class WalletRemoteDataSource {
     Future<WalletSummaryModel> getWalletSummary();
   }

   class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
     final DioClient dioClient;

     WalletRemoteDataSourceImpl({required this.dioClient});

     // 方法实现
   }
   ```

### 仓库实现（Repository Implementations）

1. **ProfileRepositoryImpl**：用户资料仓库实现
   ```dart
   class ProfileRepositoryImpl implements IProfileRepository {
     final ProfileRemoteDataSource remoteDataSource;
     final ProfileLocalDataSource localDataSource;
     final NetworkInfo networkInfo;

     ProfileRepositoryImpl({
       required this.remoteDataSource,
       required this.localDataSource,
       required this.networkInfo,
     });

     // 实现IProfileRepository接口的方法
   }
   ```

2. **WalletRepositoryImpl**：钱包仓库实现
   ```dart
   class WalletRepositoryImpl implements IWalletRepository {
     final WalletRemoteDataSource remoteDataSource;
     final NetworkInfo networkInfo;

     WalletRepositoryImpl({
       required this.remoteDataSource,
       required this.networkInfo,
     });

     // 实现IWalletRepository接口的方法
   }
   ```

## Presentation层（表现层）

### BLoC（业务逻辑组件）

1. **ProfileBloc**：用户资料状态管理
   ```dart
   class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
     final GetUserProfileUseCase getUserProfile;
     final UpdateUserProfileUseCase updateUserProfile;
     final UploadAvatarUseCase uploadAvatar;
     final SwitchUserModeUseCase switchUserMode;

     ProfileBloc({
       required this.getUserProfile,
       required this.updateUserProfile,
       required this.uploadAvatar,
       required this.switchUserMode,
     }) : super(ProfileInitial()) {
       on<GetUserProfileEvent>(_onGetUserProfile);
       on<UpdateUserProfileEvent>(_onUpdateUserProfile);
       on<UploadAvatarEvent>(_onUploadAvatar);
       on<SwitchToSellerModeEvent>(_onSwitchToSellerMode);
       on<SwitchToBuyerModeEvent>(_onSwitchToBuyerMode);
     }

     // 事件处理方法
   }
   ```

2. **WalletBloc**：钱包状态管理
   ```dart
   class WalletBloc extends Bloc<WalletEvent, WalletState> {
     final GetWalletSummaryUseCase getWalletSummary;

     WalletBloc({
       required this.getWalletSummary,
     }) : super(WalletInitial()) {
       on<GetWalletSummaryEvent>(_onGetWalletSummary);
     }

     // 事件处理方法
   }
   ```

### 页面和组件（Pages & Widgets）

1. **ProfilePage**：个人中心主页面
2. **EditProfilePage**：编辑个人资料页面
3. **WalletPage**：钱包页面
4. **ProfileSettingsPage**：设置页面

主要组件：
- **ProfileHeader**：显示用户头像、昵称
- **ProfileMenuItems**：显示功能入口列表
- **AvatarPicker**：头像选择和上传
- **WalletSummaryCard**：钱包摘要卡片

## 依赖注入

使用GetIt进行依赖注入，确保组件的松耦合和可测试性：

```dart
final sl = GetIt.instance;

void init() {
  // BLoCs
  sl.registerFactory(() => ProfileBloc(
        getUserProfile: sl(),
        updateUserProfile: sl(),
        uploadAvatar: sl(),
        switchUserMode: sl(),
      ));

  sl.registerFactory(() => WalletBloc(
        getWalletSummary: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletSummaryUseCase(sl()));
  sl.registerLazySingleton(() => SwitchUserModeUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<IProfileRepository>(() => ProfileRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  sl.registerLazySingleton<IWalletRepository>(() => WalletRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // DataSources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(dioClient: sl()));

  sl.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(sharedPreferences: sl()));

  sl.registerLazySingleton<WalletRemoteDataSource>(
      () => WalletRemoteDataSourceImpl(dioClient: sl()));
}
```

## 模块交互

Profile模块与以下模块存在交互：

1. **Authentication模块**：
   - 验证用户登录状态
   - 实现用户登出功能

2. **Common模块**：
   - 使用共享的UI组件
   - 使用共享的网络工具
   - 使用共享的错误处理机制

3. **Settings模块**：
   - 提供进入设置页面的入口

## 数据流向

1. **用户资料获取流程**：
   - 用户进入Profile页面
   - ProfileBloc触发GetUserProfileEvent
   - GetUserProfileUseCase调用ProfileRepository
   - 如果有网络连接，Repository从RemoteDataSource获取数据并缓存
   - 如果无网络连接，Repository尝试从LocalDataSource获取缓存数据
   - 数据返回通过ProfileBloc的ProfileLoaded状态传递给UI

2. **用户资料更新流程**：
   - 用户提交更新请求
   - ProfileBloc触发UpdateUserProfileEvent
   - UpdateUserProfileUseCase调用ProfileRepository
   - Repository通过RemoteDataSource提交更新请求
   - 成功后更新本地缓存
   - 通过ProfileBloc的ProfileUpdated状态通知UI更新成功

3. **钱包摘要获取流程**：
   - 用户进入Profile页面或钱包页面
   - WalletBloc触发GetWalletSummaryEvent
   - GetWalletSummaryUseCase调用WalletRepository
   - Repository从RemoteDataSource获取钱包数据
   - 数据返回通过WalletBloc的WalletSummaryLoaded状态传递给UI
