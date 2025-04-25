import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';

// 核心层导入
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';

// Seller 模块导入
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_dashboard_data.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_store_profile.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/order_refund_state.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/refund_type.dart';

// Seller 用例导入
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_tenant_audit_list_usecase.dart';

// Seller 表示层导入
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_state.dart';

// GetIt 服务定位器实例
final sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureSellerPreviewDependencies();
  runApp(const SellerPreviewApp());
}

// 卖家模块预览应用
class SellerPreviewApp extends StatelessWidget {
  const SellerPreviewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '卖家中心预览',
      debugShowCheckedModeBanner: false,
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider<SellerHomeBloc>(
        create: (_) => sl<SellerHomeBloc>()..add(const LoadDashboardData()),
        child: const SellerHomePreviewPage(),
      ),
    );
  }
}

// 临时的卖家首页预览页面
class SellerHomePreviewPage extends StatelessWidget {
  const SellerHomePreviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 确保加载店铺信息
    Future.delayed(const Duration(milliseconds: 10), () {
      BlocProvider.of<SellerHomeBloc>(context).add(const RefreshDashboardData());
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('卖家中心'),
      ),
      body: BlocBuilder<SellerHomeBloc, SellerHomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.hasError) {
            return Center(
              child: Text('错误: ${state.errorMessage}', style: const TextStyle(color: Colors.red)),
            );
          }
          
          if (state.dashboardData == null) {
            return const Center(child: Text('没有数据'));
          }
          
          final dashboardData = state.dashboardData!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 店铺信息
                if (state.storeProfile != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: state.storeProfile!.logoUrl != null 
                                ? NetworkImage(state.storeProfile!.logoUrl!) 
                                : null,
                            child: state.storeProfile!.logoUrl == null 
                                ? const Icon(Icons.store) 
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.storeProfile!.storeName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '评分: ${state.storeProfile!.averageRating ?? '-'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      state.storeProfile!.onlineFlag == true 
                                          ? Icons.circle 
                                          : Icons.circle_outlined,
                                      color: state.storeProfile!.onlineFlag == true 
                                          ? Colors.green 
                                          : Colors.grey,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      state.storeProfile!.onlineFlag == true 
                                          ? '在线' 
                                          : '离线',
                                      style: TextStyle(
                                        color: state.storeProfile!.onlineFlag == true 
                                            ? Colors.green 
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // 收入信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('收入', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildIncomeItem('总收入', '¥${dashboardData.income.total.toStringAsFixed(2)}'),
                            _buildIncomeItem('今日收入', '¥${dashboardData.income.today.toStringAsFixed(2)}'),
                            _buildIncomeItem('待结算', '¥${dashboardData.income.pending.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 订单信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('订单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOrderItem('总订单', '${dashboardData.orders.total}', Icons.receipt_long),
                            _buildOrderItem('待处理', '${dashboardData.orders.pending}', Icons.access_time),
                            _buildOrderItem('已完成', '${dashboardData.orders.completed}', Icons.check_circle),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 功能列表
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('功能', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          children: [
                            _buildFunctionItem('商品管理', Icons.inventory_2),
                            _buildFunctionItem('订单管理', Icons.receipt),
                            _buildFunctionItem('售后管理', Icons.assignment_return),
                            _buildFunctionItem('认证管理', Icons.verified_user),
                            _buildFunctionItem('店铺设置', Icons.settings),
                            _buildFunctionItem('时间管理', Icons.access_time),
                            _buildFunctionItem('消息通知', Icons.notifications),
                            _buildFunctionItem('自动回复', Icons.chat),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 统计信息
                if (dashboardData.statistics.weeklyIncome.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('近期收入', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                '收入图表（此处将实现收入趋势图表）',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildIncomeItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildOrderItem(String title, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildFunctionItem(String title, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFB66D0E)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 配置卖家模块预览依赖
Future<void> configureSellerPreviewDependencies() async {
  print('正在配置卖家模块预览依赖...');

  // 注册Mock服务
  sl.registerLazySingleton<NetworkInfo>(() => MockNetworkInfo());
  sl.registerLazySingleton<INavigationService>(() => MockNavigationService());
  sl.registerLazySingleton<ISellerRepository>(() => MockSellerRepository());

  // 注册用例
  sl.registerLazySingleton(() => GetSellerDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => GetStoreProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetSellerProductListUseCase(sl()));
  sl.registerLazySingleton(() => GetTenantAuditListUseCase(sl()));

  // 注册Bloc
  sl.registerFactory(() => SellerHomeBloc(
        sl(),
        sl(),
        sl(),
      ));

  print('卖家模块预览依赖配置完成');
}

// --- Mock 实现 ---

// Mock 网络信息
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

// Mock 导航服务
class MockNavigationService implements INavigationService {
  @override
  Future<void> goBack() async {
    print('[MockNavigation] 返回上一页');
  }

  @override
  Future<void> navigateToChat(dynamic parameter) async {
    print('[MockNavigation] 导航到聊天页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToAfterSaleApplication(dynamic parameter) async {
    print('[MockNavigation] 导航到售后申请页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToEvaluation(dynamic parameter) async {
    print('[MockNavigation] 导航到评价页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToOrderDetail(dynamic parameter) async {
    print('[MockNavigation] 导航到订单详情页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToPayment(dynamic parameter) async {
    print('[MockNavigation] 导航到支付页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToTrackingDetail(String orderId) async {
    print('[MockNavigation] 导航到物流跟踪详情页面，参数: $orderId');
  }
  
  @override
  Future<void> navigateToProductDetail(String productId) async {
    print('[MockNavigation] 导航到商品详情页面，参数: $productId');
  }
  
  @override
  Future<void> navigateToProductReview(dynamic parameter) async {
    print('[MockNavigation] 导航到商品评价页面，参数: $parameter');
  }
  
  @override
  Future<void> navigateToUser(dynamic parameter) async {
    print('[MockNavigation] 导航到用户页面，参数: $parameter');
  }
}

// Mock 卖家仓库
class MockSellerRepository implements ISellerRepository {
  @override
  Future<Either<Failure, SellerDashboardData>> getDashboardData() async {
    print('[MockSellerRepo] 获取仪表盘数据');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final dashboardData = SellerDashboardData(
      income: SellerIncomeData(
        total: 6800.0,
        today: 350.0,
        pending: 1200.0,
      ),
      orders: SellerOrdersData(
        total: 135,
        pending: 12,
        completed: 120,
        canceled: 3,
      ),
      rating: 4.8,
      notifications: SellerNotificationsData(
        unread: 5,
      ),
      statistics: SellerStatistics(
        weeklyIncome: List.generate(
          7,
          (index) => WeeklyIncomeItem(
            date: '2023-05-${10 + index}',
            amount: 100.0 + (index * 50.0),
          ),
        ),
      ),
    );
    
    return Right(dashboardData);
  }

  @override
  Future<Either<Failure, SellerStoreProfile>> getStoreProfile() async {
    print('[MockSellerRepo] 获取店铺信息');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final storeProfile = SellerStoreProfile(
      storeId: '10001',
      storeName: '测试店铺',
      logoUrl: 'https://via.placeholder.com/150',
      description: '这是一个用于测试的虚拟店铺',
      onlineFlag: true,
      joinTime: DateTime.now().subtract(const Duration(days: 180)),
      completionRate: 98.5,
      averageRating: 4.8,
      certifications: const ['实名认证', '优质卖家'],
    );
    
    return Right(storeProfile);
  }

  @override
  Future<Either<Failure, PaginatedList<SellerManagedProduct>>> getSellerProductList({
    required int pageNum,
    required int pageSize,
    String? state,
  }) async {
    print('[MockSellerRepo] 获取商品列表，页码: $pageNum, 每页数量: $pageSize, 状态: $state');
    await Future.delayed(const Duration(milliseconds: 700));
    
    final products = List.generate(
      5,
      (index) => SellerManagedProduct(
        id: 1000 + index,
        name: '测试商品 ${index + 1}',
        price: 100.0 + (index * 25.0),
        images: 'https://via.placeholder.com/300x300?text=Product${index+1}',
        description: '这是测试商品的详细描述...',
        status: state == null || state == 'all' 
            ? (index % 3 == 0 ? ProductStatus.normal : (index % 3 == 1 ? ProductStatus.disabled : ProductStatus.draft))
            : (state == 'normal' ? ProductStatus.normal : (state == 'disabled' ? ProductStatus.disabled : ProductStatus.draft)),
        sales: 10 + (index * 5),
        createTime: DateTime.now().subtract(Duration(days: 30 - index)),
      ),
    );
    
    return Right(PaginatedList<SellerManagedProduct>(
      items: products,
      total: 15,
    ));
  }

  @override
  Future<Either<Failure, PaginatedList<OrderRefund>>> getTenantAuditList({
    required int pageNum,
    required int pageSize,
  }) async {
    print('[MockSellerRepo] 获取售后审核列表，页码: $pageNum, 每页数量: $pageSize');
    await Future.delayed(const Duration(milliseconds: 800));
    
    final refunds = List.generate(
      5,
      (index) => OrderRefund(
        id: 2000 + index,
        refundState: index % 3 == 0 ? 'WAIT_AUDIT' : (index % 3 == 1 ? 'AUDIT_PASS' : 'REFUSED'),
        refundType: index % 2 == 0 ? 'ONLY_MONEY' : 'MONEY_AND_PRODUCT',
        createTime: DateTime.now().subtract(Duration(days: 5 - index)),
        refundAmount: (50 + (index * 10)).toDouble(),
        refundReason: '商品质量问题',
        refundRemarks: index % 2 == 0 ? '有质量问题，请退款' : '商品与描述不符，申请退款退货',
        images: 'https://via.placeholder.com/300x300?text=Evidence${index+1}',
        order: {
          'id': 1000 + index,
          'orderSn': 'OR${10000 + index}',
        },
        orderProductItem: {
          'productId': 100 + index,
          'productName': '测试商品 ${index + 1}',
          'productImage': 'https://via.placeholder.com/300x300?text=Product${index+1}',
          'quantity': 1,
          'unitPrice': (100 + (index * 10)).toDouble(),
        },
      ),
    );
    
    return Right(PaginatedList<OrderRefund>(
      items: refunds,
      total: 8,
    ));
  }

  @override
  Future<Either<Failure, bool>> updateProductStatus(int productId, String status) async {
    print('[MockSellerRepo] 更新商品状态：商品ID $productId, 状态 $status');
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> auditRefund({
    required int id,
    required String refundState,
    String? auditRemark,
  }) async {
    print('[MockSellerRepo] 审核退款：退款ID $id, 状态 $refundState, 备注 $auditRemark');
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(true);
  }

  // 其他未使用的接口方法实现为抛出未实现异常
  @override
  noSuchMethod(Invocation invocation) {
    print('[MockSellerRepo] 未实现的方法被调用: ${invocation.memberName}');
    return super.noSuchMethod(invocation);
  }
} 