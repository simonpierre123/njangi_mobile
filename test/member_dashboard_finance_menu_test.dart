import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_admin_dashboard_model.dart';
import 'package:njangi/ModeView/community_member_dashboard_model.dart';
import 'package:njangi/screens/community/home/member_dashboard_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('treasurer sees one finance action and its finance menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    String? selectedAction;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberDashboardPage(
            isTreasurer: true,
            health: const GroupHealthStats(
              healthPercent: 80,
              healthLabel: 'Bon',
              cashBalance: '100 000 XAF',
              membersUpToDate: 3,
              membersTotal: 4,
              pendingCount: 1,
              activeLoans: 0,
              lastUpdateLabel: 'Aujourd’hui',
            ),
            loans: const LoanStats(
              activeLoans: 0,
              pendingRequests: 0,
              overdue: 0,
              borrowingCapacity: '0 XAF',
            ),
            requiredActions: const [],
            cycle: const MemberCycleInfo(
              progressPercent: 0.5,
              progressLabel: '50 %',
              nextBeneficiary: 'Awa',
              remainingCycles: 2,
            ),
            memberStatus: const MemberStatusStats(
              total: 4,
              upToDate: 3,
              pending: 1,
              lateCount: 0,
            ),
            activity: const [],
            onQuickAction: (action) => selectedAction = action,
            onActionPay: (_) {},
            onActionTap: (_) {},
            onSeeAllMembers: () {},
            onSeeAllActivity: () {},
          ),
        ),
      ),
    );

    expect(find.text('manage_finances'), findsOneWidget);
    expect(find.text('record_contributions'), findsNothing);
    expect(find.text('manage_loans'), findsNothing);

    await tester.tap(find.text('manage_finances'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('record_contributions'), findsOneWidget);
    expect(find.text('manage_loans'), findsOneWidget);
    expect(find.text('manage_savings'), findsOneWidget);
    expect(find.text('manage_emergency_fund'), findsOneWidget);

    await tester.tap(find.text('manage_savings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(selectedAction, 'manage_savings');
  });

  testWidgets('non-treasurer does not see finance management action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberDashboardPage(
            isTreasurer: false,
            health: const GroupHealthStats(
              healthPercent: 80,
              healthLabel: 'Bon',
              cashBalance: '100 000 XAF',
              membersUpToDate: 3,
              membersTotal: 4,
              pendingCount: 1,
              activeLoans: 0,
              lastUpdateLabel: 'Aujourd’hui',
            ),
            loans: const LoanStats(
              activeLoans: 0,
              pendingRequests: 0,
              overdue: 0,
              borrowingCapacity: '0 XAF',
            ),
            requiredActions: const [],
            cycle: const MemberCycleInfo(
              progressPercent: 0.5,
              progressLabel: '50 %',
              nextBeneficiary: 'Awa',
              remainingCycles: 2,
            ),
            memberStatus: const MemberStatusStats(
              total: 4,
              upToDate: 3,
              pending: 1,
              lateCount: 0,
            ),
            activity: const [],
            onQuickAction: (_) {},
            onActionPay: (_) {},
            onActionTap: (_) {},
            onSeeAllMembers: () {},
            onSeeAllActivity: () {},
          ),
        ),
      ),
    );

    expect(find.text('manage_finances'), findsNothing);
    expect(find.text('record_contributions'), findsNothing);
  });
}
