import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_admin_dashboard_model.dart';
import 'package:njangi/screens/community/widgets/group_health_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('group health card fits a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: GroupHealthCard(
              stats: const GroupHealthStats(
                healthPercent: 82,
                healthLabel: 'health_attention',
                cashBalance: '2 450 000 FCFA',
                membersUpToDate: 8,
                membersTotal: 12,
                pendingCount: 3,
                activeLoans: 2,
                lastUpdateLabel: 'updated now',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('2 450 000 FCFA'), findsOneWidget);
  });
}
