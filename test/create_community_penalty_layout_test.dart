import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/create_community_model.dart';
import 'package:njangi/screens/community/creation/create_community_step3_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('penalty mode dropdown fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateCommunityStep3Page(
            draft: const CommunityDraft(
              penaltiesEnabled: true,
              latePenaltyAmount: '2000',
              indisciplinePenaltyAmount: '1000',
            ),
            onBack: () {},
            onContinue: (_) async => const {'success': false},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
