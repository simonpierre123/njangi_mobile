import 'package:flutter/material.dart';
import '../common/basewidget/coming_soon_page.dart';
import '../localization/app_localizations.dart';
import '../screens/auth/auth_landing_page.dart';
import '../screens/auth/register/confirm_pin_page.dart';
import '../screens/auth/register/create_pin_page.dart';
import '../screens/auth/register/phone_verified_page.dart';
import '../screens/auth/register/register_phone_page.dart';
import '../screens/auth/register/verify_otp_page.dart';
import '../screens/onboarding/onboarding_page.dart';
import 'app_routes.dart';

/// Table de routage centralisée. Les écrans ne connaissent que leurs
/// callbacks (onFinish, onContinue...) — c'est ici, et seulement ici,
/// que ces callbacks sont traduits en navigation réelle.
///
/// Provisoire : à étoffer (ou remplacer par go_router) au fur et à
/// mesure que le reste de l'app (connexion, dashboard...) est construit.
class AppRouter {
  AppRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void _push(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(route, arguments: arguments);

  static void _replace(String route, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed(route, arguments: arguments);

  static void _pop() => navigatorKey.currentState!.pop();

  static void _toggleLanguage() {
    final next = AppLocalizations.locale.value == 'fr' ? 'en' : 'fr';
    AppLocalizations.setLocale(next);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));

      case AppRoutes.authLanding:
        return _page(AuthLandingPage(
          onCreateAccount: () => _push(AppRoutes.registerPhone),
          onLogin: () => _push(AppRoutes.comingSoon, arguments: 'Se connecter'),
          onLanguageToggle: _toggleLanguage,
          onTermsTap: () =>
              _push(AppRoutes.comingSoon, arguments: "Conditions d'utilisation"),
          onPrivacyTap: () => _push(
            AppRoutes.comingSoon,
            arguments: 'Politique de confidentialité',
          ),
        ));

      case AppRoutes.registerPhone:
        return _page(RegisterPhonePage(
          onBack: _pop,
          onLogin: () => _push(AppRoutes.comingSoon, arguments: 'Se connecter'),
          onContinue: (phone) => _push(AppRoutes.verifyOtp, arguments: phone),
        ));

      case AppRoutes.verifyOtp:
        final phone = settings.arguments as String;
        return _page(VerifyOtpPage(
          phoneNumber: phone,
          onBack: _pop,
          onEditNumber: _pop,
          onResend: () {},
          onVerified: (_) => _replace(AppRoutes.phoneVerified),
        ));

      case AppRoutes.phoneVerified:
        return _page(PhoneVerifiedPage(
          onContinue: () => _replace(AppRoutes.createPin),
        ));

      case AppRoutes.createPin:
        return _page(CreatePinPage(
          onBack: _pop,
          onPinCreated: (pin) => _push(AppRoutes.confirmPin, arguments: pin),
        ));

      case AppRoutes.confirmPin:
        final originalPin = settings.arguments as String;
        return _page(ConfirmPinPage(
          originalPin: originalPin,
          onBack: _pop,
          onConfirmed: (_) =>
              _push(AppRoutes.comingSoon, arguments: 'Tableau de bord'),
        ));

      case AppRoutes.comingSoon:
        final label = settings.arguments as String? ?? '';
        return _page(ComingSoonPage(label: label));

      default:
        return _page(OnboardingPage(
          onFinish: () => _replace(AppRoutes.authLanding),
        ));
    }
  }

  static PageRoute _page(Widget child) => MaterialPageRoute(builder: (_) => child);
}