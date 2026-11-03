import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/common/basewidget/app_button.dart';

void main() {
  testWidgets('keeps an icon button within a narrow available width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 245.3,
              child: AppButton(
                label: 'Valider cette cotisation maintenant',
                icon: Icons.send_outlined,
                iconLeading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
