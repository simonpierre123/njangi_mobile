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
      titleKey: 'notif_feed_contribution_title',
      descriptionKey: 'notif_feed_contribution_desc',
      timeLabelKey: 'notif_time_5min_ago',
      dayGroupKey: 'today_label',
      isUnread: true,
    ),
    NotificationItem(
      type: NotificationType.member,
      icon: Icons.person_add_alt,
      iconBg: AppColors.notificationIconBgMuted,
      iconColor: AppColors.neutralGreenGrayLight,
      titleKey: 'notif_feed_new_member_title',
      descriptionKey: 'notif_feed_new_member_desc',
      timeLabelKey: 'notif_time_2h_ago',
      dayGroupKey: 'today_label',
    ),
    NotificationItem(
      type: NotificationType.loan,
      icon: Icons.savings_outlined,
      iconBg: AppColors.tagRedBg,
      iconColor: AppColors.alertRed,
      titleKey: 'notif_feed_loan_request_title',
      descriptionKey: 'notif_feed_loan_request_desc',
      timeLabelKey: 'yesterday_label',
      dayGroupKey: 'yesterday_label',
    ),
    NotificationItem(
      type: NotificationType.meeting,
      icon: Icons.notifications,
      iconBg: AppColors.notificationIconBgMuted,
      iconColor: AppColors.neutralGreenGray,
      titleKey: 'notif_feed_meeting_reminder_title',
      descriptionKey: 'notif_feed_meeting_reminder_desc',
      timeLabelKey: 'yesterday_label',
      dayGroupKey: 'yesterday_label',
    ),
  ];
}