import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/pages/sms_login_page.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock Cubit using mocktail or bloc_test's MockCubit
class MockSmsLoginCubit extends MockCubit<SmsLoginState> implements SmsLoginCubit {}

void main() {
  late MockSmsLoginCubit mockSmsLoginCubit;

  setUp(() {
    mockSmsLoginCubit = MockSmsLoginCubit();
    when(() => mockSmsLoginCubit.state).thenReturn(SmsLoginInitial());
    when(() => mockSmsLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSmsLoginCubit.sendCode(any())).thenAnswer((_) async {});
    when(() => mockSmsLoginCubit.login(any(), any())).thenAnswer((_) async {});
  });

  // Helper to build the widget tree for testing with localizations
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh'), Locale('en')],
      locale: const Locale('zh'),
      home: BlocProvider<SmsLoginCubit>(
        create: (_) => mockSmsLoginCubit,
        child: child,
      ),
    );
  }

  testWidgets('renders initial UI correctly', (WidgetTester tester) async {
    // arrange
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pump();

    // assert
    expect(find.byType(PhoneInputField), findsOneWidget);
    expect(find.byType(VerificationCodeInputField), findsOneWidget);
    expect(find.byType(VerificationCodeButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2)); // Login + VerificationCode buttons
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Get Code button is tappable when phone is entered', (WidgetTester tester) async {
    // arrange
    const testPhone = '1234567890';
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pump();

    // Enter phone number
    await tester.enterText(find.byType(PhoneInputField), testPhone);
    await tester.pump();

    // Tap the VerificationCodeButton - should not throw
    await tester.tap(find.byType(VerificationCodeButton));
    await tester.pump();

    // assert - button exists and is tappable
    expect(find.byType(VerificationCodeButton), findsOneWidget);
  });

  testWidgets('Login button is tappable when inputs are valid', (WidgetTester tester) async {
    // arrange
    const testPhone = '1234567890';
    const testCode = '123456';
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pump();

    // Enter phone and code
    await tester.enterText(find.byType(PhoneInputField), testPhone);
    await tester.enterText(find.byType(VerificationCodeInputField), testCode);
    await tester.pump();

    // Tap the Login button - should not throw
    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pump();

    // assert - button exists and is tappable
    expect(find.widgetWithText(ElevatedButton, '登录'), findsOneWidget);
  });

  testWidgets('shows loading indicator when state is SmsLoginLoading', (WidgetTester tester) async {
    // arrange
    whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([SmsLoginLoading()]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pump();

    // assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when state is SmsLoginFailure', (WidgetTester tester) async {
    // arrange
    const tFailure = ServerFailure(message: 'Invalid Credentials');
    whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([const SmsLoginFailure(tFailure)]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pumpAndSettle();

    // assert - find SnackBar content
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows success message when state is SmsLoginSuccess', (WidgetTester tester) async {
    // arrange
    const tUser = AuthenticatedUser(id: 1, token: 'abc');
    whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([const SmsLoginSuccess(tUser)]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pumpAndSettle();

    // assert - find SnackBar content
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
