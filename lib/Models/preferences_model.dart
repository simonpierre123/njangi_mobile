import 'package:flutter/material.dart';

/// Une préférence de l'écran "Préférences" (Profil).
///
/// [valueLabel] est optionnel — "Format régional" n'affiche qu'un
/// chevron, sans pastille de valeur actuelle.
class PreferenceItem {
  const PreferenceItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.titleKey,
    required this.subtitleKey,
    this.valueLabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String titleKey;
  final String subtitleKey;
  final String? valueLabel;
}