import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import '../../../Models/Notification.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Carte d'une notification — fond teinté + pastille verte si non lue,
/// fond blanc bordé sinon.
class NotificationFeedCard extends StatelessWidget {
  const NotificationFeedCard({
    super.key,
    required this.item,
    required this.onOpenInvitation,
    required this.onMarkAsRead,
  });

  final Notification item;
  final VoidCallback onOpenInvitation;
  final VoidCallback onMarkAsRead;

  IconData get _icon => switch (item.eventType) {
    'COTISATION' => Icons.account_balance_wallet_outlined,
    'MEMBRE_REJOINT' => Icons.person_add_alt_outlined,
    'PRET' => Icons.savings_outlined,
    'REUNION_ALERTE' => Icons.event_outlined,
    'INVITATION_GROUPE' ||
    'INVITATION_PROCHAINS_CYCLES' => Icons.group_add_outlined,
    _ => switch (item.scope) {
      'CYCLE' => Icons.autorenew_outlined,
      'GROUPE' => Icons.groups_outlined,
      _ => Icons.notifications_none_outlined,
    },
  };

  String get _scopeLabel => switch (item.scope) {
    'GROUPE' => AppLocalizations.t('notification_scope_group'),
    'CYCLE' => AppLocalizations.t('notification_scope_cycle'),
    _ => AppLocalizations.t('notification_scope_user'),
  };

  String get _typeLabel => switch (item.eventType) {
    'COTISATION' => AppLocalizations.t('notification_type_contribution'),
    'MEMBRE_REJOINT' => AppLocalizations.t('notification_type_member'),
    'PRET' => AppLocalizations.t('notification_type_loan'),
    'REUNION_ALERTE' => AppLocalizations.t('notification_type_meeting'),
    'INVITATION_GROUPE' => AppLocalizations.t('notification_type_invitation'),
    'INVITATION_PROCHAINS_CYCLES' => AppLocalizations.t(
      'notification_type_next_cycle_invitation',
    ),
    _ => item.eventType,
  };

  @override
  Widget build(BuildContext context) {
    final createdAt = item.createdAt?.toLocal();
    final timeLabel =
        createdAt == null
            ? ''
            : DateFormat.yMMMd(
              AppLocalizations.locale.value,
            ).add_Hm().format(createdAt);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: item.isInvitation || item.isRead ? null : onMarkAsRead,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceMd.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: item.isRead ? AppColors.inputBorder : AppColors.mintPale,
              width: item.isRead ? 1 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          item.isInvitation
                              ? AppColors.tagMintBg
                              : item.scope == 'CYCLE'
                              ? AppColors.tagRedBg
                              : AppColors.notificationIconBgMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icon,
                      size: 18,
                      color:
                          item.isInvitation
                              ? AppColors.primaryDark
                              : AppColors.neutralGreenGray,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceSm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color:
                                !item.isRead
                                    ? AppColors.secondaryGreen
                                    : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: AppDimensions.spaceXs.w,
                          runSpacing: AppDimensions.spaceXs.h,
                          children: [
                            _Badge(label: _typeLabel),
                            _Badge(label: _scopeLabel),
                          ],
                        ),
                        if (timeLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (item.isInvitation) ...[
                SizedBox(height: AppDimensions.spaceSm.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onOpenInvitation,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(AppLocalizations.t('notification_details')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );
  }
}
