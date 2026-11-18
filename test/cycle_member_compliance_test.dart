import 'package:flutter_test/flutter_test.dart';
import 'package:njangi/ModeView/community_members_model.dart';

void main() {
  test('parses current-turn contribution and unpaid loans per member', () {
    final overview = CycleMemberComplianceOverview.fromJson({
      'cycle_id': 'cycle-1',
      'devise': 'XAF',
      'tour_courant': {'periode': 'TOUR-2', 'date_echeance': '2026-11-06'},
      'membres': [
        {
          'id': 'membership-1',
          'utilisateur_id': 'user-1',
          'nom': 'Membre Exemple',
          'role': 'MEMBRE',
          'date_adhesion': '2022-01-03',
          'photo': 'avatars/user.jpg',
          'cotisation_statut': 'EN_ATTENTE',
          'cotisation_validee': false,
          'total_cotise_tontine': 75000,
          'est_a_jour': false,
          'prets_a_rembourser': [
            {
              'id': 'loan-1',
              'solde_restant': 25000,
              'date_remboursement_souhaitee': '2026-12-01',
            },
          ],
        },
      ],
    });

    final member = overview.members.single;
    expect(overview.currentPeriod, 'TOUR-2');
    expect(overview.currentDueDate, '2026-11-06');
    expect(member.userId, 'user-1');
    expect(member.photoUrl, 'avatars/user.jpg');
    expect(member.compliance.contributionStatus, 'EN_ATTENTE');
    expect(member.compliance.contributionValidated, isFalse);
    expect(member.compliance.totalTontineContribution, 75000);
    expect(member.compliance.loans.single.remainingAmount, 25000);
    expect(member.isUpToDate, isFalse);
  });
}
