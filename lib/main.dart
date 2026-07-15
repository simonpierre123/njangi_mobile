import 'package:flutter/material.dart';
import 'common/basewidget/coming_soon_page.dart';
import 'localization/app_localizations.dart';
import 'screens/auth/auth_landing_page.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'utils/app_theme.dart';

void main() {

  runApp(const NjangiApp());
}

class NjangiApp extends StatelessWidget {
  const NjangiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild l'app entière quand AppLocalizations.locale change.
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.locale,
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Njangi',
          theme: AppTheme.light,
          home: const _OpeningFlow(),
        );
      },
    );
  }
}


class _OpeningFlow extends StatelessWidget {
  const _OpeningFlow();

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onFinish: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _AuthLanding()),
      ),
    );
  }
}

class _AuthLanding extends StatelessWidget {
  const _AuthLanding();

  @override
  Widget build(BuildContext context) {
    return AuthLandingPage(
      onCreateAccount: () => _goToPlaceholder(context, 'Créer un compte'),
      onLogin: () => _goToPlaceholder(context, 'Se connecter'),
      onLanguageToggle: () {
        // Toggle provisoire fr/en, en attendant ta vraie logique de
        // détection/persistance de la langue.
        final next = AppLocalizations.locale.value == 'fr' ? 'en' : 'fr';
        AppLocalizations.setLocale(next);
      },
      onTermsTap: () => _goToPlaceholder(context, "Conditions d'utilisation"),
      onPrivacyTap: () =>
          _goToPlaceholder(context, 'Politique de confidentialité'),
    );
  }

  void _goToPlaceholder(BuildContext context, String label) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComingSoonPage(label: label)),
    );
  }
}