import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/cycle_dashboard_priorities_model.dart';

void main() {
  test('dashboard priority counts are parsed from the API payload', () {
    final priorities = CycleDashboardPriorities.fromJson({
      'cycle_id': 'cycle-uuid',
      'cotisations_en_attente': 3,
      'demandes_pret_en_attente': 2,
      'membres_en_retard': 1,
      'date_echeance_tour_courant': '2026-11-03',
      'membres_en_retard_liste': [
        {'id': 'membership-1', 'nom': 'Membre en retard'},
      ],
      'sante_groupe': {
        'score': 82,
        'membres_a_jour': 8,
        'membres_total': 10,
        'prets_actifs': 2,
        'cotisations_en_attente': 3,
      },
    });

    expect(priorities.pendingTontineContributions, 3);
    expect(priorities.pendingLoanRequests, 2);
    expect(priorities.overdueMembers, 1);
    expect(priorities.currentTourDueDate, DateTime(2026, 11, 3));
    expect(priorities.overdueMemberList.single.name, 'Membre en retard');
    expect(priorities.groupHealthScore, 82);
    expect(priorities.membersUpToDate, 8);
    expect(priorities.totalMembers, 10);
    expect(priorities.activeLoans, 2);
    expect(priorities.pendingContributions, 3);
  });

  test('group health endpoint payload is parsed for community members', () {
    final health = CycleGroupHealth.fromJson({
      'score': 82,
      'membres_a_jour': 8,
      'membres_total': 10,
      'prets_actifs': 2,
      'cotisations_en_attente': 3,
    });

    expect(health.score, 82);
    expect(health.membersUpToDate, 8);
    expect(health.totalMembers, 10);
    expect(health.activeLoans, 2);
    expect(health.pendingContributions, 3);
  });

  test('pending contribution details include the member and payment proof', () {
    final contribution = PendingTontineContribution.fromJson({
      'id': 'operation-1',
      'montant': 20000,
      'periode': 'TOUR-2',
      'date_operation': '2026-11-03',
      'mode_paiement': 'MOBILE_MONEY',
      'operateur': 'MTN',
      'reference_paiement': 'ref-123',
      'preuve_paiement': 'preuves/paiement.jpg',
      'membre': {
        'utilisateur_nom': 'Nom enregistré',
        'utilisateur': {'prenom': 'Jean', 'nom': 'Dupont'},
      },
    });

    expect(contribution.id, 'operation-1');
    expect(contribution.memberName, 'Jean Dupont');
    expect(contribution.amount, 20000);
    expect(contribution.period, 'TOUR-2');
    expect(contribution.receiptPath, 'preuves/paiement.jpg');
  });

  test('pending loan request details are parsed from the API payload', () {
    final request = PendingLoanRequest.fromJson({
      'id': 'loan-request-1',
      'membre_groupe_name': 'Amina',
      'montant_demande': '75000',
      'motif': 'Frais médicaux',
      'date_remboursement_souhaitee': '2027-02-04',
      'created_at': '2026-11-03T08:30:00Z',
    });

    expect(request.id, 'loan-request-1');
    expect(request.memberName, 'Amina');
    expect(request.amount, 75000);
    expect(request.reason, 'Frais médicaux');
    expect(request.createdAt, DateTime(2026, 11, 3));
    expect(request.repaymentDate, DateTime(2027, 2, 4));
  });
}
