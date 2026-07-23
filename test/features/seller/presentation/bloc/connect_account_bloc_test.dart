import 'package:bloc_test/bloc_test.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/stripe_connect_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_event.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStripeConnectDataSource implements IStripeConnectRemoteDataSource {
  String? createdCountry;
  Object? createError;

  @override
  Future<ConnectAccountStatus> createConnectAccount(String country) async {
    createdCountry = country;
    if (createError != null) throw createError!;
    return const ConnectAccountStatus(
      status: ConnectStatus.pendingOnboarding,
      accountId: 'acct_test',
    );
  }

  @override
  Future<String> getOnboardingLink() async => 'https://connect.stripe.test';

  @override
  Future<ConnectAccountStatus> getAccountStatus({bool refresh = false}) async =>
      ConnectAccountStatus.notCreated();

  @override
  Future<String> createAccountSession() async => 'secret';
}

void main() {
  late _FakeStripeConnectDataSource dataSource;

  blocTest<ConnectAccountBloc, ConnectAccountState>(
    'passes the selected country into account creation',
    build: () {
      dataSource = _FakeStripeConnectDataSource();
      return ConnectAccountBloc(dataSource: dataSource);
    },
    act: (bloc) => bloc.add(const CreateConnectAccount(country: 'SG')),
    expect: () => <ConnectAccountState>[
      ConnectAccountLoading(),
      const ConnectAccountOnboardingReady(
        onboardingUrl: 'https://connect.stripe.test',
      ),
    ],
    verify: (_) {
      expect(dataSource.createdCountry, 'SG');
    },
  );

  blocTest<ConnectAccountBloc, ConnectAccountState>(
    'shows the country validation message returned by the backend',
    build: () {
      final dataSource = _FakeStripeConnectDataSource()
        ..createError = ServerException(
          message: '请选择收款账户所在国家或地区',
        );
      return ConnectAccountBloc(dataSource: dataSource);
    },
    act: (bloc) => bloc.add(const CreateConnectAccount(country: '')),
    expect: () => <ConnectAccountState>[
      ConnectAccountLoading(),
      const ConnectAccountError(message: '请选择收款账户所在国家或地区'),
    ],
  );
}
