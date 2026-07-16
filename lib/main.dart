import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'localization/app_localizations.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Détection automatique de la langue du téléphone : anglais -> 'en',
  // tout le reste -> 'fr' (marché francophone par défaut).
  final deviceLocale = ui.PlatformDispatcher.instance.locale;
  AppLocalizations.setLocale(deviceLocale.languageCode == 'en' ? 'en' : 'fr');

  runApp(const NjangiApp());
}

class NjangiApp extends StatelessWidget {
  const NjangiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild l'app entière quand AppLocalizations.locale change
    // (bascule manuelle via l'icône globe, ou détection au démarrage).
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.locale,
      builder: (context, _, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Njangi',
          theme: AppTheme.light,
          navigatorKey: AppRouter.navigatorKey,
          initialRoute: AppRoutes.onboarding,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}