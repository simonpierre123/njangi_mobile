import 'package:flutter/material.dart';

/// Catégorie d'une notification — sert au filtrage (Cotisations/Prêts).
enum NotificationType { contribution, member, loan, meeting }

/// Une notification du fil d'actualité (onglet "Notifications" de
/// l'accueil).
///
/// TODO (Njoya) : à remplacer par le vrai flux de l'API — alimenté pour
/// l'instant par datasource/notification_feed_mock_datasource.dart.
/// Titre/description/horodatage ne sont volontairement pas traduits via
/// AppLocalizations (contenu dynamique, pas texte d'interface) — même
/// convention que le reste des données mock de l'app.
class NotificationItem {
  const NotificationItem({
    required this.type,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.dayGroup,
    this.isUnread = false,
  });

  final NotificationType type;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final String timeLabel;
  final String dayGroup; // libellé de la section (déjà localisé côté datasource)
  final bool isUnread;
}