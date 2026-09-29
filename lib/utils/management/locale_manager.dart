import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager {
  static const String _languageCodeKey = 'language_code';

  /// Récupère la langue sauvegardée ou détecte celle du téléphone
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageCodeKey);

    if (code != null && ['fr', 'en'].contains(code)) {
      return Locale(code);
    }

    // Détecter la langue du téléphone
    final deviceLocale = window.locale.languageCode;

    // Si la langue est supportée (fr/en), on la retourne
    if (['fr', 'en'].contains(deviceLocale)) {
      return Locale(deviceLocale);
    }

    // Sinon, français par défaut
    return const Locale('fr');
  }

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  // --- Gestion des tokens ---
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
  }
}
