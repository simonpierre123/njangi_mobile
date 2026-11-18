import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_member_dashboard_model.dart';
import 'package:njangi/screens/community/widgets/member_cycle_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('member cycle card fits a narrow viewport with a long name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: MemberCycleCard(
              info: MemberCycleInfo(
                progressPercent: 0.5,
                progressLabel: '1/2 tours',
                nextBeneficiary:
                    'Alexandria Marie-Claire de la très longue famille',
                remainingBeneficiaries: 2,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
