import '../Models/beneficiary_model.dart';

/// Données mock de l'onglet Bénéficiaires, en attendant l'API.
class CommunityBeneficiaryMockDatasource {
  CommunityBeneficiaryMockDatasource._();

  static const current = CurrentBeneficiary(
    name: 'Jean Tchoumba',
    subtitle: 'Cycle 8 en cours',
    statusLabel: 'En attente',
    amount: '600 000 FCFA',
  );

  static const stats = BeneficiaryStats(
    totalMembers: 15,
    potAmount: '2.45M FCFA',
    servedCount: 7,
    remainingCount: 5,
  );

  static const passageOrder = [
    PassageOrderEntry(
      order: 8,
      name: 'Jean Tchoumba',
      statusLabel: 'Actuel · Cycle 8/12',
      dateBadge: "AUJOURD'HUI",
      isCurrent: true,
    ),
    PassageOrderEntry(
      order: 9,
      name: 'Marie Ndzié',
      statusLabel: 'Prochain · Cycle 9/12',
      dateBadge: 'OCT 2023',
      isCurrent: false,
    ),
    PassageOrderEntry(
      order: 10,
      name: 'Alex Ngassa',
      statusLabel: 'Cycle 10/12',
      dateBadge: 'NOV 2023',
      isCurrent: false,
    ),
  ];

  static const payoutHistory = [
    PayoutHistoryEntry(name: 'Thomas L.', cycleLabel: 'Cycle 7/12', amount: '600 000 FCFA'),
    PayoutHistoryEntry(name: 'Sophie M.', cycleLabel: 'Cycle 6/12', amount: '600 000 FCFA'),
  ];
}