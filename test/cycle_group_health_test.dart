import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/cycle_dashboard_priorities_model.dart';

void main() {
  test('parses member counts classified for the current cycle turn', () {
    final health = CycleGroupHealth.fromJson({
      'score': 75,
      'membres_total': 5,
      'membres_a_jour': 2,
      'membres_en_attente': 2,
      'membres_en_retard': 1,
      'prets_actifs': 0,
      'cotisations_en_attente': 0,
    });

    expect(health.totalMembers, 5);
    expect(health.membersUpToDate, 2);
    expect(health.membersPending, 2);
    expect(health.membersOverdue, 1);
  });
}
