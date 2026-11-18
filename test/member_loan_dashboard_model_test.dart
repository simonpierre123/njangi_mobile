import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/member_loan_dashboard_model.dart';

void main() {
  test('loan eligibility reflects the configured seniority threshold', () {
    final dashboard = MemberLoanDashboard.fromJson({
      'cycle': {'numero': 2, 'groupe_nom': 'Groupe test'},
      'profil': {'nom': 'Membre'},
      'module_pret_actif': true,
      'anciennete_min_pret_mois': 3,
      'anciennete_mois': 2,
      'montant_max_pret': 150000,
      'historique_exemplaire': false,
      'pret_actif': null,
      'prochaine_echeance': null,
      'operations': [],
    });

    expect(dashboard.canRequestLoan, isFalse);
    expect(dashboard.groupName, 'Groupe test');
    expect(dashboard.maximumLoanAmount, 150000);
    expect(dashboard.seniorityMonths, 2);
  });

  test('an active loan prevents a new request regardless of seniority', () {
    final dashboard = MemberLoanDashboard.fromJson({
      'cycle': {'numero': 1, 'groupe_nom': 'Groupe test'},
      'profil': {'nom': 'Membre'},
      'module_pret_actif': true,
      'anciennete_min_pret_mois': 0,
      'anciennete_mois': 12,
      'montant_max_pret': 100000,
      'historique_exemplaire': false,
      'pret_actif': {
        'statut': 'EN_COURS',
        'montant_emprunte': 50000,
        'montant_rembourse': 10000,
        'solde_restant': 40000,
      },
      'prochaine_echeance': null,
      'operations': [],
    });

    expect(dashboard.canRequestLoan, isFalse);
    expect(dashboard.activeLoan?.remainingBalance, 40000);
  });
}
