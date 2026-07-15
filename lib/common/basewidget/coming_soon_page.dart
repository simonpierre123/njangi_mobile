import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Écran temporaire affiché tant que la destination réelle n'est pas
/// encore construite. À retirer du projet une fois tous les écrans du
/// parcours prêts et le routage définitif branché.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: Center(
        child: Text(
          '$label\n(écran à venir)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}