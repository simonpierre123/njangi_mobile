class CurrentBeneficiary {
  const CurrentBeneficiary({
    required this.name,
    required this.subtitle,
    required this.statusLabel,
    required this.amount,
  });

  final String name;
  final String subtitle; // "Cycle 8 en cours"
  final String statusLabel; // "En attente"
  final String amount;
}

class BeneficiaryStats {
  const BeneficiaryStats({
    required this.totalMembers,
    required this.potAmount,
    required this.servedCount,
    required this.remainingCount,
  });

  final int totalMembers;
  final String potAmount;
  final int servedCount;
  final int remainingCount;
}

/// Une entrée de l'ordre de passage — [order] est la position dans le
/// cycle (8, 9, 10...), [isCurrent] distingue le bénéficiaire du cycle
/// en cours des suivants.
class PassageOrderEntry {
  const PassageOrderEntry({
    required this.order,
    required this.name,
    required this.statusLabel,
    required this.dateBadge,
    required this.isCurrent,
    this.membershipId,
    this.isPaid = false,
    this.photoUrl,
  });

  final String? membershipId;
  final int order;
  final String name;
  final String statusLabel; // "Actuel · Cycle 8/12" / "Prochain · Cycle 9/12"
  final String dateBadge; // "AUJOURD'HUI" / "OCT 2023"
  final bool isCurrent;
  final bool isPaid;
  final String? photoUrl;

  PassageOrderEntry copyWith({
    String? membershipId,
    int? order,
    String? name,
    String? statusLabel,
    String? dateBadge,
    bool? isCurrent,
    bool? isPaid,
    String? photoUrl,
  }) {
    return PassageOrderEntry(
      membershipId: membershipId ?? this.membershipId,
      order: order ?? this.order,
      name: name ?? this.name,
      statusLabel: statusLabel ?? this.statusLabel,
      dateBadge: dateBadge ?? this.dateBadge,
      isCurrent: isCurrent ?? this.isCurrent,
      isPaid: isPaid ?? this.isPaid,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

List<PassageOrderEntry> reorderPassageOrder(
  List<PassageOrderEntry> entries,
  int oldIndex,
  int newIndex,
) {
  final reordered = List<PassageOrderEntry>.of(entries);
  if (newIndex > oldIndex) newIndex -= 1;
  final movedEntry = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, movedEntry);

  final currentIndex = reordered.indexWhere((entry) => !entry.isPaid);
  return [
    for (var index = 0; index < reordered.length; index++)
      reordered[index].copyWith(
        order: index + 1,
        isCurrent: index == currentIndex,
      ),
  ];
}

class PayoutHistoryEntry {
  const PayoutHistoryEntry({
    required this.name,
    required this.cycleLabel,
    required this.amount,
  });

  final String name;
  final String cycleLabel;
  final String amount;
}
