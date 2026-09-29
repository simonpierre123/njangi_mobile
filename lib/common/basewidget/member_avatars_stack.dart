import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Avatars membres empilés (cercles superposés) + compteur total.
/// Reproduit exactement l'empilement de la maquette : 2 cercles neutres
/// suivis d'un 3e cercle affichant le total, puis le total répété en
/// texte à côté (fidèle au design fourni).
class MemberAvatarsStack extends StatelessWidget {
  const MemberAvatarsStack({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 24,
          child: Stack(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: AppColors.neutralGrayLight),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.neutralGrayLight.withValues(alpha: 0.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.mintLight.withValues(alpha: 0.6),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}