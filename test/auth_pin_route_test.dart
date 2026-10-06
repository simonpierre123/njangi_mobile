import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/routes/app_router.dart';
import 'package:njangi/routes/app_routes.dart';
import 'package:njangi/screens/auth/register/confirm_pin_page.dart';

void main() {
  testWidgets('registration passes the created PIN and phone to confirmation', (
    tester,
  ) async {
    await _createPinAndOpenConfirmation(
      tester,
      createPinArguments: '+237600000000',
    );

    final confirmation = tester.widget<ConfirmPinPage>(
      find.byType(ConfirmPinPage),
    );
    expect(confirmation.originalPin, '1234');
    expect(confirmation.telephone, '+237600000000');
    expect(confirmation.resetToken, isNull);
  });

  testWidgets('PIN reset passes the created PIN, phone, and reset token', (
    tester,
  ) async {
    await _createPinAndOpenConfirmation(
      tester,
      createPinArguments: {
        'telephone': '+237600000000',
        'resetPin': true,
        'resetToken': 'reset-token',
      },
    );

    final confirmation = tester.widget<ConfirmPinPage>(
      find.byType(ConfirmPinPage),
    );
    expect(confirmation.originalPin, '1234');
    expect(confirmation.telephone, '+237600000000');
    expect(confirmation.resetToken, 'reset-token');
  });
}

Future<void> _createPinAndOpenConfirmation(
  WidgetTester tester, {
  required Object createPinArguments,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: Builder(
        builder:
            (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.of(context).pushNamed(
                        AppRoutes.createPin,
                        arguments: createPinArguments,
                      ),
                  child: const Text('open'),
                ),
              ),
            ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  for (final digit in ['1', '2', '3', '4']) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }

  await tester.tap(find.text('continue_button'));
  await tester.pumpAndSettle();
}
