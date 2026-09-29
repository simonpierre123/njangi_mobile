import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../../../Controllers_distant/AuthController.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/management/storage_manager.dart';

/// Étape 3/3 de la connexion : Saisie du code PIN & Authentification Biométrique
class EnterPinPage extends StatefulWidget {
  const EnterPinPage({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onPinEntered,
    this.canGoBack = true,
    this.allowBiometricUnlock = false,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final ValueChanged<String> onPinEntered;
  final bool canGoBack;
  final bool allowBiometricUnlock;

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _pin = '';
  bool _isLoading = false;
  bool _isAuthenticating = false;
  bool _canCheckBiometrics = false;
  bool _biometricEnabled = true;

  // Animation pour secouer les dots en cas d'erreur de PIN
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _checkBiometrics();
  }

  void _setupAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 24.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  /// Vérifie la disponibilité des capteurs biométriques
  Future<void> _checkBiometrics() async {
    if (!widget.allowBiometricUnlock) return;

    try {
      final biometricEnabled = await StorageManager.getBiometricEnabled();
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _biometricEnabled = biometricEnabled;
          _canCheckBiometrics = canCheck && isDeviceSupported;
        });
      }
    } catch (e) {
      debugPrint('Erreur vérification biométrique: $e');
    }
  }

  /// Déclenche la vérification Biométrique (Empreinte / FaceID)
  Future<void> _authenticateWithBiometrics() async {
    if (!widget.allowBiometricUnlock || !_canCheckBiometrics) return;

    if (!_biometricEnabled) {
      await showDialog<void>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              icon: const Icon(Icons.fingerprint_rounded),
              title: Text(AppLocalizations.t('biometric_disabled_title')),
              content: Text(AppLocalizations.t('biometric_disabled_message')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.t('dialog_ok')),
                ),
              ],
            ),
      );
      return;
    }

    if (_isLoading || _isAuthenticating || !widget.allowBiometricUnlock) {
      return;
    }

    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason:
            AppLocalizations.t('biometric_auth_reason') ??
            'Scannez votre empreinte ou visage pour vous connecter',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        HapticFeedback.mediumImpact();
        widget.onPinEntered('BIOMETRIC_SUCCESS');
      }
    } on PlatformException catch (e) {
      debugPrint('Erreur auth biométrique: $e');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _onDigit(String digit) {
    // if (_pin.length >= 5 || _isLoading) return;
    if (_pin.length >= 4 || _isLoading) return;

    HapticFeedback.lightImpact();
    final nextPin = _pin + digit;
    setState(() => _pin = nextPin);

    if (nextPin.length == 4) {
      // if (nextPin.length == 5) {
      _handleLogin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty || _isLoading) return;

    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _handleLogin() async {
    if (_pin.length != 4) return;
    // if (_pin.length != 5) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthController.login(
        telephone: widget.phoneNumber,
        pin: _pin,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        HapticFeedback.mediumImpact();
        widget.onPinEntered(_pin);
      } else {
        _triggerErrorState(
          response['message'] ??
              AppLocalizations.t('invalid_credentials') ??
              'Code PIN incorrect',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _triggerErrorState(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerErrorState(String message) {
    HapticFeedback.vibrate();
    _shakeController.forward(from: 0.0).then((_) => _shakeController.reset());
    _showSnackBar(message, isError: true);
    setState(() => _pin = '');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: AppColors.textOnPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canGoBack,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar:
            widget.canGoBack
                ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDeep,
                    ),
                    onPressed: widget.onBack,
                  ),
                )
                : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),

                          // Avatar central vert
                          Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 80,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Titre principal
                          Text(
                            AppLocalizations.t('login_pin_title') ??
                                'Entrez votre code PIN pour accéder\nà votre compte.',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Sous-titre avec icône de cadenas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  AppLocalizations.t('login_pin_subtitle') ??
                                      'Entrez votre code PIN',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section Indicateur de PIN avec animation Shake (5 dots)
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  _shakeAnimation.value *
                                      (1 -
                                          (_shakeController.value - 0.5).abs() *
                                              2),
                                  0,
                                ),
                                child: child,
                              );
                            },
                            child: ModernPinDots(
                              pinLength: _pin.length,
                              maxLength: 4,
                              // maxLength: 5,
                            ),
                          ),

                          // Indicateur de chargement
                          SizedBox(
                            height: 32,
                            child:
                                _isLoading
                                    ? const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      ),
                                    )
                                    : null,
                          ),

                          const Spacer(),

                          // Clavier numérique épuré
                          ModernNumericKeypad(
                            onDigit: _onDigit,
                            onBackspace: _onBackspace,
                            showBiometric:
                                widget.allowBiometricUnlock &&
                                _canCheckBiometrics,
                            onBiometric: _authenticateWithBiometrics,
                            isDisabled: _isLoading,
                          ),

                          const SizedBox(height: 28),

                          // Bouton PIN oublié
                          GestureDetector(
                            onTap: () {
                              // Action pour récupérer le PIN
                            },
                            child: Text(
                              AppLocalizations.t('forgot_pin') ??
                                  'PIN oublié ?',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryDark,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Version de l'application en bas
                          const Text(
                            'Paysika v3.1.23(872)',
                            style: TextStyle(
                              color: AppColors.neutralGreenGray,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMPOSANTS DESIGN SYSTÈME (PIN DOTS & KEYPAD)
// =============================================================================

/// Indicateur de saisie de PIN à 4 cercles contournés
class ModernPinDots extends StatelessWidget {
  // const ModernPinDots({super.key, required this.pinLength, this.maxLength = 5});
  const ModernPinDots({super.key, required this.pinLength, this.maxLength = 4});

  final int pinLength;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primaryDark : Colors.transparent,
            border: Border.all(
              color:
                  isFilled ? AppColors.primaryDark : AppColors.neutralGreenGray,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// Clavier numérique sur-mesure ergonomique (Style épuré sans fond)
class ModernNumericKeypad extends StatelessWidget {
  const ModernNumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.showBiometric,
    required this.onBiometric,
    this.isDisabled = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool showBiometric;
  final VoidCallback onBiometric;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['biometric', '0', 'backspace'], // Ordre ergonomique ajusté
    ];

    return Column(
      children:
          keys.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    row.map((key) {
                      if (key == 'backspace') {
                        return _buildIconButton(
                          icon: Icons.backspace_outlined,
                          color: AppColors.neutralDark,
                          onPressed: isDisabled ? null : onBackspace,
                        );
                      }

                      if (key == 'biometric') {
                        if (!showBiometric) {
                          return const SizedBox(width: 72, height: 60);
                        }
                        return _buildIconButton(
                          icon: Icons.fingerprint_rounded,
                          color: AppColors.primaryDark,
                          onPressed: isDisabled ? null : onBiometric,
                        );
                      }

                      return _buildKeyButton(
                        digit: key,
                        onPressed: isDisabled ? null : () => onDigit(key),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildKeyButton({
    required String digit,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 72,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          highlightColor: AppColors.primaryContainer10,
          splashColor: AppColors.primaryDark10,
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 72,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: color.withValues(alpha: 0.15),
          child: Center(child: Icon(icon, size: 28, color: color)),
        ),
      ),
    );
  }
}
