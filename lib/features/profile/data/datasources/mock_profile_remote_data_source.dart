import 'dart:math';

import '../models/transaction_dto.dart';
import '../models/user_profile_dto.dart';
import '../models/wallet_summary_dto.dart';
import '../models/saved_item_dto.dart';
import '../models/liked_story_dto.dart';
import 'profile_remote_data_source.dart';

/// 模拟的远程数据源，用于开发和测试
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  final Random _random = Random();

  MockProfileRemoteDataSource();

  @override
  Future<UserProfileDto> getUserProfile() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    return const UserProfileDto(
      userId: 'user123',
      nickName: '测试用户',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      onlineFlag: true,
    );
  }

  @override
  Future<UserProfileDto> updateUserProfile({
    String? nickName,  // 改为可选参数
    String? avatar,    // 添加头像参数
    bool? onlineFlag,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    return UserProfileDto(
      userId: 'user123',
      nickName: nickName ?? '测试用户',  // 提供默认值
      avatarUrl: avatar ?? 'https://randomuser.me/api/portraits/men/32.jpg',  // 使用传入的头像或默认头像
      onlineFlag: onlineFlag ?? true,
    );
  }

  @override
  Future<String> uploadAvatar({required String imageFilePath}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    return 'https://randomuser.me/api/portraits/men/${_random.nextInt(50)}.jpg';
  }

  @override
  Future<WalletSummaryDto> getWalletSummary() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    return const WalletSummaryDto(
      balance: 7037.97,
      pendingAmount: 3147.0,
      totalIncome: 15000.0,
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
    await Future.delayed(const Duration(milliseconds: 800));

    // 根据类型过滤
    var typeFilter = transactionType;
    if (transactionType == 'all') {
      typeFilter = '';
    }

    // 创建模拟数据
    final baseDate = DateTime.now();

    // 根据页码控制返回的项目数，模拟分页
    final itemCount = page <= 3 ? pageSize : _random.nextInt(pageSize);

    return List.generate(
      itemCount,
      (index) {
        bool isIncome = false;
        String description = '';
        double amount = 0;

        // 根据类型过滤
        if (typeFilter == 'income') {
          isIncome = true;
        } else if (typeFilter == 'outcome') {
          isIncome = false;
        } else {
          isIncome = _random.nextBool();
        }

        if (isIncome) {
          final incomeTypes = ['客户付款', '平台结算', '退款到账', '余额提现撤销'];
          description = incomeTypes[_random.nextInt(incomeTypes.length)];
          amount = 100 + _random.nextDouble() * 900;
        } else {
          final outcomeTypes = ['服务费', '提现', '平台手续费', '购买商品'];
          description = outcomeTypes[_random.nextInt(outcomeTypes.length)];
          amount = -(50 + _random.nextDouble() * 450);
        }

        final date = baseDate.subtract(Duration(
          days: (index * 2) + _random.nextInt(10) + ((page - 1) * pageSize),
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ));

        final transactionId = 'TR${100000 + index + ((page - 1) * pageSize)}';
        final status = _getRandomStatus();

        return TransactionDto(
          id: transactionId,
          amount: amount,
          type: isIncome ? 'income' : 'outcome',
          description: description,
          date: date,
          status: status,
        );
      },
    );
  }

  String _getRandomStatus() {
    final statuses = ['completed', 'completed', 'completed', 'pending', 'failed'];
    return statuses[_random.nextInt(statuses.length)];
  }

  @override
  Future<List<SavedItemDto>> getSavedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回空数据，这个方法暂未实现
    return [];
  }

  @override
  Future<List<LikedStoryDto>> getLikedStories({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 返回空数据，这个方法暂未实现
    return [];
  }
}
