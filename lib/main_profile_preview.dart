import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/models/user_profile_dto.dart';
import 'features/profile/data/models/wallet_summary_dto.dart';
import 'features/profile/data/models/transaction_dto.dart';
import 'features/profile/data/models/saved_item_dto.dart';
import 'features/profile/data/models/liked_story_dto.dart';
import 'features/profile/presentation/pages/simple_profile_page.dart';
import 'features/seller/presentation/pages/seller_profile_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/wallet_bloc.dart';
import 'features/profile/domain/usecases/get_wallet_summary.dart';
import 'features/profile/domain/usecases/get_wallet_transactions.dart';
import 'features/profile/domain/repositories/i_wallet_repository.dart';
import 'features/profile/data/repositories/wallet_repository_impl.dart';
import 'core/network/network_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册依赖项
  final GetIt locator = GetIt.instance;

  // 注册mock数据源
  final mockRemoteDataSource = MockProfileRemoteDataSource();
  locator.registerLazySingleton<ProfileRemoteDataSource>(() => mockRemoteDataSource);

  // 注册网络信息服务
  locator.registerLazySingleton<NetworkInfo>(() => MockNetworkInfo());

  // 注册钱包仓库
  locator.registerLazySingleton<IWalletRepository>(() => WalletRepositoryImpl(
    remoteDataSource: locator(),
    networkInfo: locator(),
  ));

  // 注册用例
  locator.registerLazySingleton(() => GetWalletSummary(locator()));
  locator.registerLazySingleton(() => GetWalletTransactions(locator()));

  // 注册BLoC
  locator.registerFactory(() => WalletBloc(
    getWalletSummary: locator(),
    getWalletTransactions: locator(),
  ));

  runApp(const ProfilePreviewApp());
}

class ProfilePreviewApp extends StatelessWidget {
  const ProfilePreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '个人中心预览',
      theme: ThemeData(
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
      ),
      home: const MainProfileScreen(),
    );
  }
}

class MainProfileScreen extends StatefulWidget {
  const MainProfileScreen({Key? key}) : super(key: key);

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen> {
  bool _isSellerMode = false;

  @override
  Widget build(BuildContext context) {
    return _isSellerMode
        ? SellerProfilePage(
            onSwitchToBuyer: () {
              setState(() {
                _isSellerMode = false;
              });
            },
          )
        : SimpleProfilePage(
            onSwitchMode: () {
              setState(() {
                _isSellerMode = true;
              });
            },
          );
  }
}

// 模拟远程数据源实现
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<String> uploadAvatar({required String imageFilePath}) async {
    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 2));
    // 返回空字符串，使用默认头像
    return "";
  }

  @override
  Future<UserProfileDto> getUserProfile() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 返回模拟数据，使用应用内部资源路径
    return const UserProfileDto(
      userId: '1',
      nickName: '测试用户',
      avatarUrl: '',
      onlineFlag: true,
    );
  }

  @override
  Future<UserProfileDto> updateUserProfile({
    required String nickName,
    bool? onlineFlag,
  }) async {
    // 模拟更新延迟
    await Future.delayed(const Duration(seconds: 1));

    return UserProfileDto(
      userId: '1',
      nickName: nickName,
      avatarUrl: '',
      onlineFlag: onlineFlag ?? true,
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
  Future<List<TransactionDto>> getWalletTransactions({
    int page = 1,
    int pageSize = 20,
    String? startDate,
    String? endDate,
    String transactionType = 'all',
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 生成模拟交易记录
    return List.generate(
      5, // 只返回少量记录作为示例
      (index) => TransactionDto(
        id: 'TR${10000 + index}',
        amount: (index % 2 == 0 ? 1 : -1) * ((index + 1) * 50.0),
        type: index % 2 == 0 ? 'income' : 'outcome',
        description: index % 2 == 0 ? '收到付款' : '购买商品',
        date: DateTime.now().subtract(Duration(days: index)),
        status: 'completed',
      ),
    );
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return []; // 返回空列表作为模拟数据
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return []; // 返回空列表作为模拟数据
  }
}

// 添加一个简单的Mock网络信息类
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
