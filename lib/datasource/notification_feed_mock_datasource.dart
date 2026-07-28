import 'package:flutter/material.dart';
import '../Models/notification_feed_model.dart';
import '../utils/app_colors.dart';

/// Données mock du fil de notifications, en attendant l'API.
class NotificationFeedMockDatasource {
  NotificationFeedMockDatasource._();

  static const items = [
    NotificationItem(
      type: NotificationType.contribution,
      icon: Icons.credit_card_outlined,
      iconBg: AppColors.mintPale,
      iconColor: AppColors.contributionRecordedIconColor,
      title: 'Cotisation enregistrée',
      description: 'Votre cotisation de 50 000 FCFA a été enregistrée avec succès.',
      timeLabel: 'Il y a 5 minutes',
      dayGroup: "Aujourd'hui",
      isUnread: true,
    ),
    NotificationItem(
      type: NotificationType.member,
      icon: Icons.person_add_alt,
      iconBg: AppColors.notificationIconBgMuted,
      iconColor: AppColors.neutralGreenGrayLight,
      title: 'Nouveau membre',
      description: 'Marie Ndzié a rejoint votre communauté.',
      timeLabel: 'Il y a 2h',
      dayGroup: "Aujourd'hui",
    ),
    NotificationItem(
      type: NotificationType.loan,
      icon: Icons.savings_outlined,
      iconBg: AppColors.tagRedBg,
      iconColor: AppColors.alertRed,
      title: 'Demande de prêt',
      description: 'Votre demande est en attente de validation.',
      timeLabel: 'Hier',
      dayGroup: 'Hier',
    ),
    NotificationItem(
      type: NotificationType.meeting,
      icon: Icons.notifications,
      iconBg: AppColors.notificationIconBgMuted,
      iconColor: AppColors.neutralGreenGray,
      title: 'Rappel de réunion',
      description: 'La réunion mensuelle est prévue pour ce samedi à 14h.',
      timeLabel: 'Hier',
      dayGroup: 'Hier',
    ),
  ];
}