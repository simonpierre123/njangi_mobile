import 'package:flutter/material.dart' hide Notification;
import '../../Models/Notification.dart';
import '../../common/basewidget/member_filter_chips.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/notification_feed_card.dart';

/// Contenu de l'onglet "Notifications" de l'accueil — filtres (Toutes/
/// Non lues/Cotisations/Prêts) + sections groupées par jour.
///
/// Comme [HomePage]/[ProfilePage], ne possède pas de Scaffold propre :
/// c'est [HomeShell] qui le fournit. La flèche retour visible en haut
/// (fidèle à la maquette) ramène simplement sur l'onglet Accueil,
/// puisqu'il n'y a rien "avant" cet onglet dans la pile.
class NotificationFeedPage extends StatefulWidget {
  const NotificationFeedPage({
    super.key,
    required this.notifications,
    required this.onBackToHome,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenInvitation,
    required this.onMarkAsRead,
  });

  final List<Notification> notifications;
  final VoidCallback onBackToHome;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<Notification> onOpenInvitation;
  final ValueChanged<Notification> onMarkAsRead;

  @override
  State<NotificationFeedPage> createState() => _NotificationFeedPageState();
}

class _NotificationFeedPageState extends State<NotificationFeedPage> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filterLabels = [
      AppLocalizations.t('filter_all_feminine'),
      AppLocalizations.t('filter_unread'),
      AppLocalizations.t('contributions_label'),
      AppLocalizations.t('loans_label'),
      AppLocalizations.t('invite_members_title'),
    ];

    final filtered =
        widget.notifications.where((n) {
            return switch (_filterIndex) {
              1 => !n.isRead,
              2 => n.eventType == 'COTISATION',
              3 => n.eventType == 'PRET',
              4 => n.isInvitation,
              _ => true,
            };
          }).toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBackToHome,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppDimensions.spaceXs.w),
              Text(
                AppLocalizations.t('nav_notifications'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemberFilterChips(
                  labels: filterLabels,
                  currentIndex: _filterIndex,
                  onChanged: (i) => setState(() => _filterIndex = i),
                ),
                SizedBox(height: AppDimensions.spaceLg.h),
                if (widget.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (widget.errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onRetry,
                          child: Text(AppLocalizations.t('invite_retry')),
                        ),
                      ],
                    ),
                  )
                else
                  _buildList(filtered),
                SizedBox(height: AppDimensions.spaceXl.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<Notification> items) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXl.h),
        child: Center(
          child: Text(
            AppLocalizations.t('no_notifications_yet'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final notification in items) ...[
          NotificationFeedCard(
            item: notification,
            onOpenInvitation: () => widget.onOpenInvitation(notification),
            onMarkAsRead: () => widget.onMarkAsRead(notification),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
        ],
      ],
    );
  }
}
