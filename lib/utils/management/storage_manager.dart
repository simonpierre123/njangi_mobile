import 'dart:convert';
import 'package:njangi/Models/user_model.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const String _tokenKey = AppConstants.userToken;
  static const String _userKey = AppConstants.userData;

  // --- TOKEN ---
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_tokenKey);
  }

  // --- USER DATA ---
  static Future<bool> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    return await prefs.setString(_userKey, userJson);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userString));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_userKey);
  }

  static Future<bool> consumeFirstHomeWelcome(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'first_home_welcome_shown_$userId';
    if (prefs.getBool(key) ?? false) return false;

    await prefs.setBool(key, true);
    return true;
  }

  // --- LOGOUT / CLEAR ALL AUTH ---
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
