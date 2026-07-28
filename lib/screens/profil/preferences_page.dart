import 'package:flutter/material.dart';
import '../../Models/preferences_model.dart';
import '../../datasource/preferences_mock_datasource.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/preference_row.dart';

/// Écran "Préférences" — Langue (branchée en direct sur
/// AppLocalizations, fonctionnelle), Apparence/Devise/Format régional
/// (affichage pour l'instant, actions vers un placeholder).
///
/// Sous-page poussée par-dessus le shell : la bottom nav visible ici
/// est purement pour rester fidèle à la maquette — n'importe quel tap
/// dessus ramène simplement au shell.
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({
    super.key,
    required this.onBack,
    required this.onOpenAppearance,
    required this.onOpenCurrency,
    required this.onOpenRegionalFormat,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenAppearance;
  final VoidCallback onOpenCurrency;
  final VoidCallback onOpenRegionalFormat;

  void _toggleLanguage() {
    final next = AppLocalizations.locale.value == 'fr' ? 'en' : 'fr';
    AppLocalizations.setLocale(next);
  }

  static const _languageItem = PreferenceItem(
    icon: Icons.language,
    iconBg: AppColors.tagMintBg,
    iconColor: AppColors.primaryDark,
    titleKey: 'language_title',
    subtitleKey: 'language_subtitle',
  );

  @override
  Widget build(BuildContext context) {
    final currentLanguageLabel = AppLocalizations.locale.value == 'fr'
        ? AppLocalizations.t('language_fr_label')
        : AppLocalizations.t('language_en_label');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('preferences_title'), onBack: onBack),
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
              PreferenceRow(
                item: _languageItem,
                valueOverride: currentLanguageLabel,
                onTap: _toggleLanguage,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              PreferenceRow(item: PreferencesMockDatasource.appearance, onTap: onOpenAppearance),
              SizedBox(height: AppDimensions.spaceSm.h),
              PreferenceRow(item: PreferencesMockDatasource.currency, onTap: onOpenCurrency),
              SizedBox(height: AppDimensions.spaceSm.h),
              PreferenceRow(item: PreferencesMockDatasource.regionalFormat, onTap: onOpenRegionalFormat),
              SizedBox(height: AppDimensions.spaceMd.h),
            ],
          ),
        ),
      ),
    );
  }
}