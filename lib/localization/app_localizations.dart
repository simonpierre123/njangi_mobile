import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../utils/management/locale_manager.dart';

/// Loads translations from assets/lang/{language}.json.
class AppLocalizations {
  AppLocalizations(this.currentLocale);

  final Locale currentLocale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [Locale('en'), Locale('fr')];

  static final ValueNotifier<String> locale = ValueNotifier<String>('fr');
  static final Map<String, Map<String, String>> _translations = {};

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<void> load() async {
    for (final languageCode in ['en', 'fr']) {
      final jsonString = await rootBundle.loadString(
        'assets/lang/$languageCode.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _translations[languageCode] = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
  }

  static void setLocale(String code) {
    if (code == 'fr' || code == 'en') {
      locale.value = code;
      unawaited(LocaleManager.saveLocale(code));
    }
  }

  static String t(String key, {List<dynamic>? args}) {
    final text = _translations[locale.value]?[key] ?? key;
    return _replaceArguments(text, args);
  }

  String translate(String key, {List<dynamic>? args}) {
    final text = _translations[currentLocale.languageCode]?[key] ?? key;
    return _replaceArguments(text, args);
  }

  static String _replaceArguments(String text, List<dynamic>? args) {
    if (args == null) {
      return text;
    }

    var currentText = text;
    for (final argument in args) {
      if (currentText.contains('%s')) {
        currentText = currentText.replaceFirst('%s', argument.toString());
      } else if (currentText.contains('%d')) {
        currentText = currentText.replaceFirst('%d', argument.toString());
      }
    }
    return currentText;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (!AppLocalizations._translations.containsKey(locale.languageCode)) {
      final jsonString = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      AppLocalizations._translations[locale.languageCode] = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
