import 'package:flutter/material.dart';
import '../../Models/notification_settings_model.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/notification_master_card.dart';
import 'widgets/notification_toggle_row.dart';

/// Écran "Notifications" — préférences groupées par section
/// (Trésorerie/Prêts/Communautés/Général). Désactiver le maître grise
/// les sections en dessous.
///
/// Sous-page poussée par-dessus le shell : la bottom nav visible ici
/// est purement pour rester fidèle à la maquette — n'importe quel tap
/// dessus ramène simplement au shell (pas de vrai changement d'onglet
/// depuis une sous-page).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.masterEnabled,
    required this.sections,
    required this.onBack,
  });

  final bool masterEnabled;
  final List<NotificationSection> sections;
  final VoidCallback onBack;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late bool _masterEnabled = widget.masterEnabled;
  late final Map<String, bool> _values = {
    for (final section in widget.sections)
      for (final item in section.items) item.key: item.value,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('nav_notifications'), onBack: widget.onBack),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t('push_notifications_title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              SizedBox(height: AppDimensions.spaceXs.h),
              Text(
                AppLocalizations.t('push_notifications_desc'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
              NotificationMasterCard(
                label: AppLocalizations.t('enable_notifications'),
                value: _masterEnabled,
                onChanged: (v) => setState(() => _masterEnabled = v),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Opacity(
                opacity: _masterEnabled ? 1 : 0.5,
                child: IgnorePointer(
                  ignoring: !_masterEnabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in widget.sections) ...[
                        Text(
                          AppLocalizations.t(section.title).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceSm.h),
                        for (var i = 0; i < section.items.length; i++) ...[
                          NotificationToggleRow(
                            label: AppLocalizations.t(section.items[i].label),
                            value: _values[section.items[i].key] ?? section.items[i].value,
                            enabled: _masterEnabled,
                            onChanged: (v) => setState(() => _values[section.items[i].key] = v),
                          ),
                          if (i != section.items.length - 1) SizedBox(height: AppDimensions.spaceSm.h),
                        ],
                        SizedBox(height: AppDimensions.spaceLg.h),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}