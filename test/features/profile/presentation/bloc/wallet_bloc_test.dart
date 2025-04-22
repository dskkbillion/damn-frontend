import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/entities/wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_wallet_transactions.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/wallet_bloc.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/wallet_event.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/wallet_state.dart';

@GenerateMocks([GetWalletSummary, GetWalletTransactions])
import 'wallet_bloc_test.mocks.dart';

void main() {
  late WalletBloc bloc;
  late MockGetWalletSummary mockGetWalletSummary;
  late MockGetWalletTransactions mockGetWalletTransactions;

  setUp(() {
    mockGetWalletSummary = MockGetWalletSummary();
    mockGetWalletTransactions = MockGetWalletTransactions();
    bloc = WalletBloc(
      getWalletSummary: mockGetWalletSummary,
      getWalletTransactions: mockGetWalletTransactions,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('初始状态应该是WalletInitial', () {
    expect(bloc.state, const WalletInitial());
  });

  final tWalletSummary = WalletSummary(
    balance: 1000.0,
    pendingAmount: 200.0,
    totalIncome: 5000.0,
    hasBankCard: false,
    hasPaymentPassword: false,
    recentTransactionsCount: 0,
  );

  group('FetchWalletSummary', () {
    blocTest<WalletBloc, WalletState>(
      '应该发出 [WalletLoading, WalletSummaryLoaded] 当获取钱包摘要成功',
      build: () {
        when(mockGetWalletSummary(any))
            .thenAnswer((_) async => Right(tWalletSummary));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchWalletSummary()),
      expect: () => [
        const WalletLoading(),
        WalletSummaryLoaded(tWalletSummary),
      ],
      verify: (_) {
        verify(mockGetWalletSummary(NoParams()));
      },
    );

    blocTest<WalletBloc, WalletState>(
      '应该发出 [WalletLoading, WalletError] 当获取钱包摘要失败',
      build: () {
        when(mockGetWalletSummary(any))
            .thenAnswer((_) async => Left(ServerFailure(message: '服务器错误')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchWalletSummary()),
      expect: () => [
        const WalletLoading(),
        const WalletError('服务器错误，请稍后再试'),
      ],
    );
  });

  group('RefreshWalletSummary', () {
    blocTest<WalletBloc, WalletState>(
      '应该只发出 WalletSummaryLoaded 当刷新钱包摘要成功 (不显示加载状态)',
      build: () {
        when(mockGetWalletSummary(any))
            .thenAnswer((_) async => Right(tWalletSummary));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshWalletSummary()),
      expect: () => [
        WalletSummaryLoaded(tWalletSummary),
      ],
      verify: (_) {
        verify(mockGetWalletSummary(NoParams()));
      },
    );

    blocTest<WalletBloc, WalletState>(
      '应该只发出 WalletError 当刷新钱包摘要失败 (不显示加载状态)',
      build: () {
        when(mockGetWalletSummary(any))
            .thenAnswer((_) async => Left(NetworkFailure(message: '网络连接失败')));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshWalletSummary()),
      expect: () => [
        const WalletError('网络连接失败，请检查网络设置'),
      ],
    );
  });
}
