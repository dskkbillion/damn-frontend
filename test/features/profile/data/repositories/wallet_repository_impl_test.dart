import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/profile/data/models/wallet_summary_dto.dart';
import 'package:dskk_flutter_refactor/features/profile/data/repositories/wallet_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/repositories/i_wallet_repository.dart';

@GenerateMocks([ProfileRemoteDataSource, NetworkInfo])
import 'wallet_repository_impl_test.mocks.dart';

void main() {
  late WalletRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WalletRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tWalletSummaryDto = WalletSummaryDto(
    balance: 1000.0,
    pendingAmount: 200.0,
    totalIncome: 5000.0,
  );

  final tWalletSummary = WalletSummary(
    balance: 1000.0,
    pendingAmount: 200.0,
    totalIncome: 5000.0,
    hasBankCard: false, // 默认值
    hasPaymentPassword: false, // 默认值
    recentTransactionsCount: 0, // 默认值
  );

  group('getWalletSummary', () {
    test('应该检查设备是否在线', () async {
      // 安排
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getWalletSummary())
          .thenAnswer((_) async => tWalletSummaryDto);

      // 行动
      await repository.getWalletSummary();

      // 断言
      verify(mockNetworkInfo.isConnected);
    });

    group('设备在线', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('应该从远程数据源获取钱包摘要', () async {
        // 安排
        when(mockRemoteDataSource.getWalletSummary())
            .thenAnswer((_) async => tWalletSummaryDto);

        // 行动
        final result = await repository.getWalletSummary();

        // 断言
        verify(mockRemoteDataSource.getWalletSummary());
        expect(result, equals(Right(tWalletSummary)));
      });

      test('应该返回ServerFailure当远程调用失败时', () async {
        // 安排
        when(mockRemoteDataSource.getWalletSummary())
            .thenThrow(ServerException(message: '服务器错误'));

        // 行动
        final result = await repository.getWalletSummary();

        // 断言
        verify(mockRemoteDataSource.getWalletSummary());
        expect(result, equals(Left(ServerFailure(message: '服务器错误'))));
      });
    });

    group('设备离线', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('应该返回NetworkFailure当设备离线时', () async {
        // 行动
        final result = await repository.getWalletSummary();

        // 断言
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(NetworkFailure(message: '无网络连接'))));
      });
    });
  });
}
