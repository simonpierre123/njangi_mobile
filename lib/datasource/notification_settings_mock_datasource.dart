import '../Models/notification_settings_model.dart';

/// Données mock des préférences de notifications, en attendant l'API.
class NotificationSettingsMockDatasource {
  NotificationSettingsMockDatasource._();

  static const masterEnabled = true;

  static const sections = [
    NotificationSection(
      title: 'notif_section_treasury',
      items: [
        NotificationToggleItem(key: 'new_contribution', label: 'notif_new_contribution', value: true),
        NotificationToggleItem(key: 'due_reminder', label: 'notif_due_reminder', value: true),
        NotificationToggleItem(key: 'late_contribution', label: 'notif_late_contribution', value: true),
        NotificationToggleItem(key: 'receipt_available', label: 'notif_receipt_available', value: true),
      ],
    ),
    NotificationSection(
      title: 'notif_section_loans',
      items: [
        NotificationToggleItem(key: 'new_loan_request', label: 'notif_new_loan_request', value: true),
        NotificationToggleItem(key: 'loan_approved', label: 'notif_loan_approved', value: true),
        NotificationToggleItem(key: 'loan_rejected', label: 'notif_loan_rejected', value: true),
        NotificationToggleItem(key: 'repayment_due', label: 'notif_repayment_due', value: true),
        NotificationToggleItem(key: 'repayment_recorded', label: 'notif_repayment_recorded', value: false),
      ],
    ),
    NotificationSection(
      title: 'notif_section_communities',
      items: [
        NotificationToggleItem(key: 'community_invitation', label: 'notif_community_invitation', value: true),
        NotificationToggleItem(key: 'new_member', label: 'notif_new_member', value: false),
        NotificationToggleItem(key: 'role_change', label: 'notif_role_change', value: true),
        NotificationToggleItem(key: 'rules_modification', label: 'notif_rules_modification', value: true),
        NotificationToggleItem(key: 'meeting_scheduled', label: 'notif_meeting_scheduled', value: true),
      ],
    ),
    NotificationSection(
      title: 'notif_section_general',
      items: [
        NotificationToggleItem(key: 'app_updates', label: 'notif_app_updates', value: true),
        NotificationToggleItem(key: 'tips_news', label: 'notif_tips_news', value: false),
        NotificationToggleItem(key: 'planned_maintenance', label: 'notif_planned_maintenance', value: true),
      ],
    ),
  ];
}