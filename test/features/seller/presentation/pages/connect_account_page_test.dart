import 'package:dskk_flutter_refactor/features/seller/data/datasources/stripe_connect_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/stripe_connect_country.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/connect_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _UnlinkedStripeConnectDataSource
    implements IStripeConnectRemoteDataSource {
  @override
  Future<ConnectAccountStatus> createConnectAccount(String country) async =>
      const ConnectAccountStatus(
        status: ConnectStatus.pendingOnboarding,
        accountId: 'acct_test',
      );

  @override
  Future<String> getOnboardingLink() async => 'https://connect.stripe.test';

  @override
  Future<ConnectAccountStatus> getAccountStatus({bool refresh = false}) async =>
      ConnectAccountStatus.notCreated();

  @override
  Future<String> createAccountSession() async => 'secret';
}

void main() {
  Future<void> pumpUnlinkedPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ConnectAccountBloc(
            dataSource: _UnlinkedStripeConnectDataSource(),
          ),
          child: const ConnectAccountPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ElevatedButton startButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '开始绑定'),
      );

  testWidgets('requires a country and enables Singapore', (tester) async {
    await pumpUnlinkedPage(tester);

    expect(find.text('收款账户所在国家或地区'), findsOneWidget);
    expect(startButton(tester).onPressed, isNull);

    final countryField =
        find.byType(DropdownButtonFormField<StripeConnectCountry>);
    await tester.tap(countryField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('新加坡').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('新加坡 的本地要求'), findsOneWidget);
    expect(startButton(tester).onPressed, isNotNull);
  });

  testWidgets('keeps an unavailable Southeast Asia country disabled',
      (tester) async {
    await pumpUnlinkedPage(tester);

    final countryField =
        find.byType(DropdownButtonFormField<StripeConnectCountry>);
    await tester.tap(countryField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('菲律宾（暂未开放）').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('菲律宾 暂未开放'), findsOneWidget);
    expect(startButton(tester).onPressed, isNull);
  });
}
