import '../Models/contribution_model.dart';

/// Données mock pour "Enregistrer une cotisation" / "Contribution",
/// en attendant l'API.
class ContributionMockDatasource {
  ContributionMockDatasource._();

  static const memberDue = ContributionMemberSummary(
    name: 'Alice M.',
    expectedAmount: '50 000 FCFA',
    statusLabel: 'En attente',
  );

  static const detail = ContributionDetail(
    memberName: 'Jean Tchoumba',
    amount: '50 000 FCFA',
    periodLabel: 'Cotisation de Juillet 2026',
    expectedAmount: '50 000 FCFA',
    paidAmount: '50 000 FCFA',
    statusLabel: 'À jour',
    dateLabel: '11 octobre 2023',
    timeLabel: '18:45',
    paymentMethodLabel: 'Espèces',
    reference: 'Aucune',
    recordedByName: 'Alex Ngassa',
    recordedByRole: 'ADMIN',
    recordedAtLabel: '11 Oct. 2023 à 18:50',
    observation: 'Cotisation réglée intégralement en début de réunion.',
  );
}