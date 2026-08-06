import 'package:flutter/material.dart';
import '../../Models/notification_feed_model.dart';
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
  });

  final List<NotificationItem> notifications;
  final VoidCallback onBackToHome;

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
    ];

    final filtered = widget.notifications.where((n) {
      return switch (_filterIndex) {
        1 => n.isUnread,
        2 => n.type == NotificationType.contribution,
        3 => n.type == NotificationType.loan,
        _ => true,
      };
    }).toList();

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
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              SizedBox(width: AppDimensions.spaceXs.w),
              Text(
                AppLocalizations.t('nav_notifications'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemberFilterChips(
                  labels: filterLabels,
                  currentIndex: _filterIndex,
                  onChanged: (i) => setState(() => _filterIndex = i),
                ),
                SizedBox(height: AppDimensions.spaceLg.h),
                _buildGroupedList(filtered),
                SizedBox(height: AppDimensions.spaceXl.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedList(List<NotificationItem> items) {
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

    final widgets = <Widget>[];
    String? lastGroup;
    for (final item in items) {
      if (item.dayGroupKey != lastGroup) {
        if (lastGroup != null) widgets.add(SizedBox(height: AppDimensions.spaceLg.h));
        widgets.add(Text(
          AppLocalizations.t(item.dayGroupKey).toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
        ));
        widgets.add(SizedBox(height: AppDimensions.spaceSm.h));
        lastGroup = item.dayGroupKey;
      } else {
        widgets.add(SizedBox(height: AppDimensions.spaceSm.h));
      }
      widgets.add(NotificationFeedCard(item: item));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}