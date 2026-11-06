import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_admin_dashboard_model.dart';

void main() {
  test('parses loan statistics and cycle borrowing limit from the API', () {
    final stats = LoanStats.fromJson({
      'prets_actifs': 3,
      'demandes_en_attente': '2',
      'prets_en_retard': 1,
      'capacite_emprunt': 200000,
      'devise': 'XAF',
    });

    expect(stats.activeLoans, 3);
    expect(stats.pendingRequests, 2);
    expect(stats.overdue, 1);
    expect(stats.borrowingCapacity, 200000);
    expect(stats.currency, 'XAF');
  });

  test('rejects invalid loan statistic values', () {
    expect(
      () => LoanStats.fromJson({
        'prets_actifs': 'unknown',
        'demandes_en_attente': 0,
        'prets_en_retard': 0,
        'capacite_emprunt': 0,
      }),
      throwsFormatException,
    );
  });
}
