import 'dart:async';
import 'package:flutter/material.dart';
import 'package:njangi/datasource/api_service.dart';
import 'localization/app_localizations.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils/management/locale_manager.dart';
import 'utils/management/storage_manager.dart';

class _SessionTimeout extends StatefulWidget {
  const _SessionTimeout({required this.child});

  final Widget child;

  @override
  State<_SessionTimeout> createState() => _SessionTimeoutState();
}

class _SessionTimeoutState extends State<_SessionTimeout>
    with WidgetsBindingObserver {
  static const _timeout = Duration(minutes: 5);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppRouter.sessionActive.addListener(_sessionChanged);
    _sessionChanged();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppRouter.sessionActive.removeListener(_sessionChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _sessionChanged() {
    if (!AppRouter.sessionActive.value) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _resetTimer();
  }

  void _resetTimer() {
    if (!AppRouter.sessionActive.value) return;
    _timer?.cancel();
    _timer = Timer(_timeout, AppRouter.lockSession);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerDown: (_) => _resetTimer(), child: widget.child);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.initializeInterceptors();

  final savedLocale = await LocaleManager.getSavedLocale();
  AppLocalizations.setLocale(savedLocale.languageCode);
  await AppLocalizations.load();

  final token = await StorageManager.getToken();
  final user = await StorageManager.getUser();
  final hasSavedSession =
      token != null &&
      token.isNotEmpty &&
      user != null &&
      user.telephone.isNotEmpty;

  runApp(
    NjangiApp(
      initialRoute: hasSavedSession ? AppRoutes.enterPin : AppRoutes.onboarding,
      initialArguments:
          hasSavedSession
              ? {'telephone': user.telephone, 'locked': true}
              : null,
    ),
  );
}

class NjangiApp extends StatelessWidget {
  const NjangiApp({
    super.key,
    required this.initialRoute,
    this.initialArguments,
  });

  final String initialRoute;
  final Object? initialArguments;

  @override
  Widget build(BuildContext context) {
    // Rebuild l'app entière quand AppLocalizations.locale change
    // (bascule manuelle via l'icône globe, ou détection au démarrage).
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.locale,
      builder: (context, languageCode, __) {
        return _SessionTimeout(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Njangi',
            theme: AppTheme.light,
            locale: Locale(languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: AppRouter.navigatorKey,
            initialRoute: initialRoute,
            onGenerateInitialRoutes:
                (routeName) => [
                  AppRouter.onGenerateRoute(
                    RouteSettings(name: routeName, arguments: initialArguments),
                  ),
                ],
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}
