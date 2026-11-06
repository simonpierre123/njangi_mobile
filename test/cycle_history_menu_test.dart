import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/screens/community/rapport/cycle_history_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('history menu lists categories and reports the selection', (
    tester,
  ) async {
    String? selectedType;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomSheet: CycleHistoryMenu(
            onSelect: (type) => selectedType = type,
          ),
        ),
      ),
    );

    expect(find.text('history_choose_type'), findsOneWidget);
    expect(find.text('history_contributions'), findsOneWidget);
    expect(find.text('history_savings'), findsOneWidget);
    expect(find.text('history_loans'), findsOneWidget);

    await tester.tap(find.text('history_contributions'));

    expect(selectedType, 'cotisations');
  });
}
