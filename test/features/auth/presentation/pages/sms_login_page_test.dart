import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart'; // For mocking cubits/blocs easily

import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_state.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/pages/sms_login_page.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/phone_input_field.dart'; // Assuming these widgets exist
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_input_field.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/widgets/verification_code_button.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // For Failure type

// Mock Cubit using mocktail or bloc_test's MockCubit
class MockSmsLoginCubit extends MockCubit<SmsLoginState> implements SmsLoginCubit {}

// Mock NavigatorObserver if needed for testing navigation (but we decided against it here)
// @GenerateMocks([NavigatorObserver])
// import 'sms_login_page_test.mocks.dart';

void main() {
  late MockSmsLoginCubit mockSmsLoginCubit;

  setUp(() {
    mockSmsLoginCubit = MockSmsLoginCubit();
    // Remove stubbing the state here, rely on initialState in whenListen
    // when(() => mockSmsLoginCubit.state).thenReturn(SmsLoginInitial());
  });

  // Helper to build the widget tree for testing
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<SmsLoginCubit>(
        create: (_) => mockSmsLoginCubit,
        child: child,
      ),
      // If testing navigation:
      // navigatorObservers: [mockNavigatorObserver],
      // routes: { '/home': (_) => Scaffold(body: Text('Home Page'))},
    );
  }

  testWidgets('renders initial UI correctly', (WidgetTester tester) async {
    // arrange
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));

    // assert
    expect(find.byType(PhoneInputField), findsOneWidget);
    expect(find.byType(VerificationCodeInputField), findsOneWidget);
    expect(find.byType(VerificationCodeButton), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '登录'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing); // No loading initially
  });

  testWidgets('calls cubit.sendCode when Get Code button is tapped', (WidgetTester tester) async {
    // arrange
    const testPhone = '1234567890';
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));

    // Enter phone number
    await tester.enterText(find.byType(PhoneInputField), testPhone);
    await tester.pump(); // Allow time for state updates if any

    // Tap the VerificationCodeButton (assuming it has identifiable text or key)
    // We might need to find the inner button if VerificationCodeButton wraps it.
    // Finding by type is simpler here if there's only one.
    await tester.tap(find.byType(VerificationCodeButton));
    await tester.pump();

    // assert
    verify(() => mockSmsLoginCubit.sendCode(testPhone)).called(1);
  });

   testWidgets('calls cubit.login when Login button is tapped with valid input', (WidgetTester tester) async {
    // arrange
     const testPhone = '1234567890';
     const testCode = '123456';
    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));

     // Enter phone and code
    await tester.enterText(find.byType(PhoneInputField), testPhone);
    await tester.enterText(find.byType(VerificationCodeInputField), testCode);
    await tester.pump();

    // Tap the Login button
    await tester.tap(find.widgetWithText(ElevatedButton, '登录'));
    await tester.pump(); // Allow time for state updates (e.g., loading)

    // assert
    verify(() => mockSmsLoginCubit.login(testPhone, testCode)).called(1);
  });

   testWidgets('shows loading indicator when state is SmsLoginLoading', (WidgetTester tester) async {
    // arrange
    // Make the cubit emit loading state
    whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([SmsLoginLoading()]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
     await tester.pump(); // Process the emitted state

    // assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Check if button is disabled (onPressed == null)
    final loginButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '登录'));
    expect(loginButton.onPressed, isNull);
  });

  testWidgets('shows error message when state is SmsLoginFailure', (WidgetTester tester) async {
    // arrange
    final tFailure = ServerFailure(message: 'Invalid Credentials');
     whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([SmsLoginFailure(tFailure)]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pumpAndSettle(); // pumpAndSettle allows time for SnackBar animations

    // assert
    expect(find.text('登录失败: Invalid Credentials'), findsOneWidget); // SnackBar text
     expect(find.byType(CircularProgressIndicator), findsNothing); // No loading
  });

   testWidgets('shows success message when state is SmsLoginSuccess', (WidgetTester tester) async {
    // arrange
    const tUser = AuthenticatedUser(id: 1, token: 'abc');
     whenListen(
      mockSmsLoginCubit,
      Stream.fromIterable([SmsLoginSuccess(tUser)]),
      initialState: SmsLoginInitial(),
    );

    await tester.pumpWidget(buildTestableWidget(const SmsLoginPage()));
    await tester.pumpAndSettle();

    // assert
    expect(find.text('登录成功!'), findsOneWidget); // SnackBar text
    // Navigation should be handled elsewhere, so no navigation verification here.
  });

   // TODO: Add tests for input validation failures (if implemented in the page/widgets)
   // TODO: Add tests for VerificationCodeButton state changes (e.g., countdown)

}
