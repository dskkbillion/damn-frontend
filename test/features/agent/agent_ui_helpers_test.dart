import 'package:dskk_flutter_refactor/features/agent/data/agent_repository.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_ui_helpers.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the friendly message and adds a canonical code in debug',
      (tester) async {
    String? rendered;
    await tester.pumpWidget(_app(Builder(
      builder: (context) {
        rendered = agentErrorMessage(
          context,
          const AgentApiException(
            'server details must not be shown',
            'STATE_TRANSITION_DENIED',
          ),
        );
        return Text(rendered!);
      },
    )));

    expect(rendered, contains('could not complete this Agent operation'));
    expect(rendered, endsWith('[STATE_TRANSITION_DENIED]'));
    expect(rendered, isNot(contains('server details must not be shown')));
  });

  testWidgets('rejects non-canonical error codes from the diagnostic suffix',
      (tester) async {
    String? rendered;
    await tester.pumpWidget(_app(Builder(
      builder: (context) {
        rendered = agentErrorMessage(
          context,
          const AgentApiException('sensitive details', 'BAD CODE\nsecret'),
        );
        return Text(rendered!);
      },
    )));

    expect(rendered, contains('could not complete this Agent operation'));
    expect(rendered, isNot(contains('BAD CODE')));
    expect(rendered, isNot(contains('sensitive details')));
  });
}

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
