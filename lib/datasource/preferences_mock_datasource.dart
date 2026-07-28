import 'package:flutter/material.dart';
import '../Models/preferences_model.dart';
import '../utils/app_colors.dart';

/// Données mock des préférences, en attendant l'API.
/// La ligne "Langue" est un cas particulier : sa valeur affichée et son
/// action sont branchées en direct sur AppLocalizations dans
/// preferences_page.dart, pas sur ces données statiques.
class PreferencesMockDatasource {
  PreferencesMockDatasource._();

  static const appearance = PreferenceItem(
    icon: Icons.contrast,
    iconBg: AppColors.neutralDark,
    iconColor: AppColors.white,
    titleKey: 'appearance_title',
    subtitleKey: 'appearance_subtitle',
    valueLabel: 'appearance_value',
  );

  static const currency = PreferenceItem(
    icon: Icons.payments_outlined,
    iconBg: AppColors.tagMintBg,
    iconColor: AppColors.primaryDark,
    titleKey: 'currency_title',
    subtitleKey: 'currency_subtitle',
    valueLabel: 'currency_value',
  );

  static const regionalFormat = PreferenceItem(
    icon: Icons.calendar_month_outlined,
    iconBg: AppColors.tagRedBg,
    iconColor: AppColors.alertRed,
    titleKey: 'regional_format_title',
    subtitleKey: 'regional_format_subtitle',
  );
}