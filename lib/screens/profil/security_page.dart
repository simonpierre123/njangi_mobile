import 'package:flutter/material.dart';
import '../../Models/profile_model.dart';
import '../../common/basewidget/simple_app_bar.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'widgets/security_action_row.dart';
import 'widgets/security_status_card.dart';

/// Écran "Sécurité" — état global du compte + actions d'authentification
/// et d'accès. Poussé par-dessus le shell (Navigator.push) — pas de
/// bottom nav ici, c'est une sous-page, pas un onglet.
class SecurityPage extends StatefulWidget {
  const SecurityPage({
    super.key,
    required this.status,
    required this.onBack,
    required this.onChangePin,
    required this.onOpenConnectedDevices,
    required this.onLogoutAllDevices,
  });

  final SecurityStatus status;
  final VoidCallback onBack;
  final VoidCallback onChangePin;
  final VoidCallback onOpenConnectedDevices;
  final VoidCallback onLogoutAllDevices;

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  // TODO (Njoya) : état local uniquement pour l'instant — brancher sur
  // la vraie préférence utilisateur (et le vrai capteur biométrique)
  // une fois l'API/le device disponibles.
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SimpleAppBar(title: AppLocalizations.t('security_title'), onBack: widget.onBack),
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
              SecurityStatusCard(status: widget.status),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('authentication_section').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SecurityActionRow(
                icon: Icons.password_outlined,
                title: AppLocalizations.t('change_pin_title'),
                subtitle: AppLocalizations.t('change_pin_subtitle'),
                onTap: widget.onChangePin,
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SecurityActionRow(
                icon: Icons.fingerprint,
                title: AppLocalizations.t('biometric_auth_title'),
                toggleValue: _biometricEnabled,
                onToggleChanged: (v) => setState(() => _biometricEnabled = v),
              ),
              SizedBox(height: AppDimensions.spaceLg.h),
              Text(
                AppLocalizations.t('access_section').toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
              SizedBox(height: AppDimensions.spaceSm.h),
              SecurityActionRow(
                icon: Icons.devices_outlined,
                title: AppLocalizations.t('connected_devices_title'),
                subtitle: AppLocalizations.t('connected_devices_subtitle'),
                onTap: widget.onOpenConnectedDevices,
              ),
              SizedBox(height: AppDimensions.spaceXl),
              Center(
                child: GestureDetector(
                  onTap: widget.onLogoutAllDevices,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.logout, size: 14, color: AppColors.alertRed),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.t('logout_all_devices'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.alertRed),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceXl.h),
            ],
          ),
        ),
      ),
    );
  }
}