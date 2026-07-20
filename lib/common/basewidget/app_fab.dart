import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Bouton d'action flottant réutilisable ("+" pour ajouter une communauté,
/// etc.).
class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}