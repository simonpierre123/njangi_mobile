import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// AppBar simple réutilisable : flèche retour + titre, fond transparent.
/// Pour les écrans "sous-page" qui n'ont pas besoin de l'en-tête enrichi
/// de CommunityAppBar (icône, rôle, cycle).
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SimpleAppBar({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
    );
  }
}