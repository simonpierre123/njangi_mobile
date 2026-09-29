import 'package:flutter/material.dart';

/// Catégorie d'une notification — sert au filtrage (Cotisations/Prêts).
enum NotificationType { contribution, member, loan, meeting }

/// Une notification du fil d'actualité (onglet "Notifications" de
/// l'accueil).
///
/// TODO (Njoya) : à remplacer par le vrai flux de l'API — alimenté pour
/// l'instant par datasource/notification_feed_mock_datasource.dart.
/// Contrairement à d'autres contenus mock de l'app, titre/description/
/// horodatage/groupe passent ici par des clés AppLocalizations (pas du
/// texte brut) pour que le changement de langue s'applique bien.
class NotificationItem {
  const NotificationItem({
    required this.type,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.titleKey,
    required this.descriptionKey,
    required this.timeLabelKey,
    required this.dayGroupKey,
    this.isUnread = false,
  });

  final NotificationType type;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String titleKey;
  final String descriptionKey;
  final String timeLabelKey;
  final String dayGroupKey;
  final bool isUnread;
}