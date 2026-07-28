import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

/// Ligne label (gauche) / valeur (droite) — section "Détails".
/// [valueWidget] permet de passer un badge/icône+texte plutôt qu'un
/// simple texte (ex: "Statut" avec pastille colorée).
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          valueWidget ??
              Text(
                value ?? '—',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
        ],
      ),
    );
  }
}