import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/member_savings_dashboard_model.dart';

void main() {
  test(
    'dashboard parses balances, counters, operations, and savings share',
    () {
      final dashboard = MemberSavingsDashboard.fromJson({
        'solde_membre': 650000,
        'solde_total': 750000,
        'transactions_validees_membre': 9,
        'transactions_validees_total': 15,
        'transactions_en_attente_membre': 2,
        'devise': 'XAF',
        'operations': [
          {
            'id': 'operation-1',
            'type': 'EPARGNE',
            'montant': 20000,
            'statut': 'VALIDE',
            'date_operation': '2026-10-01',
            'periode': 'OCTOBRE',
          },
        ],
      });

      expect(dashboard.memberBalance, 650000);
      expect(dashboard.totalBalance, 750000);
      expect(dashboard.balanceShare, closeTo(0.8667, 0.0001));
      expect(dashboard.validatedMemberCount, 9);
      expect(dashboard.totalValidatedCount, 15);
      expect(dashboard.pendingMemberCount, 2);
      expect(dashboard.operations.single.status, 'VALIDE');
      expect(dashboard.operations.single.amount, 20000);
    },
  );

  test('dashboard share is zero when total savings balance is zero', () {
    const dashboard = MemberSavingsDashboard(
      memberBalance: 0,
      totalBalance: 0,
      validatedMemberCount: 0,
      totalValidatedCount: 0,
      pendingMemberCount: 0,
      currency: 'XAF',
      operations: [],
    );

    expect(dashboard.balanceShare, 0);
  });
}
