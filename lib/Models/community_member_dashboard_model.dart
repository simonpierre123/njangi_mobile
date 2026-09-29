import 'package:flutter/material.dart';

/// Modèles spécifiques au tableau de bord "membre" (non-admin) d'une
/// communauté. Les autres modèles partagés (santé du groupe, statut des
/// membres, activité) restent dans community_admin_dashboard_model.dart —
/// pas de duplication.

/// Une action requise pour le membre courant (cotisation due, réunion...).
/// Si [actionLabel] est fourni, la card affiche un bouton d'action ;
/// sinon elle affiche un simple chevron (information seule).
class RequiredActionItem {
  const RequiredActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
}

/// Progression du cycle en cours, vue simplifiée côté membre (pas de
/// badge "Cycle X sur Y" affiché ici, contrairement à la vue admin).
class MemberCycleInfo {
  const MemberCycleInfo({
    required this.progressPercent,
    required this.progressLabel,
    required this.nextBeneficiary,
    required this.remainingCycles,
  });

  final double progressPercent; // 0.0 à 1.0
  final String progressLabel;
  final String nextBeneficiary;
  final int remainingCycles;
}