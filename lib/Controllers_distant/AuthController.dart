import 'package:flutter/material.dart';
import 'package:njangi/Models/user_model.dart';
import 'package:njangi/utils/app_constants.dart';
import 'package:njangi/utils/management/storage_manager.dart';
import '../../../localization/app_localizations.dart';
import '../../datasource/api_service.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Envoie l'OTP au numéro de téléphone spécifié
  Future<Map<String, dynamic>> sendOtp(String telephone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.sendOtp,
        data: {'telephone': telephone},
      );

      _isLoading = false;
      notifyListeners();

      // Si le serveur a retourné un code d'erreur (ex: TOO_MANY_REQUESTS)
      if (response['code'] != null) {
        final errorCode = response['code'].toString();

        // Cherche la traduction dans fr.json (ex: AppLocalizations.t('TOO_MANY_REQUESTS'))
        final translatedMessage = AppLocalizations.t(errorCode);

        if (translatedMessage.isNotEmpty) {
          response['translated_message'] = translatedMessage;
        } else {
          // Si le code n'est pas trouvé dans fr.json, on affiche le message brut du serveur ou SERVER_ERROR
          response['translated_message'] =
              response['message'] ?? AppLocalizations.t('SERVER_ERROR');
        }
      }

      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'code': 'SERVER_ERROR',
        'message': AppLocalizations.t('otp_send_error'),
        'translated_message': AppLocalizations.t('otp_send_error'),
      };
    }
  }

  /// Inscription de l'utilisateur avec le téléphone et le code OTP
  Future<Map<String, dynamic>> register({
    required String telephone,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.register,
        data: {'telephone': telephone, 'code': code},
      );

      _isLoading = false;
      notifyListeners();

      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'code': 'UNKNOWN_ERROR',
        'message': AppLocalizations.t('register_error'),
      };
    }
  }

  /// Définition du code PIN de l'utilisateur avec son numéro de téléphone
  Future<Map<String, dynamic>> setPin({
    required String telephone,
    required String pin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.setPin,
        data: {'telephone': telephone, 'pin': pin},
      );

      if (response['success'] != true) {
        _isLoading = false;
        notifyListeners();
        return response;
      }

      final loginResponse = await login(telephone: telephone, pin: pin);
      _isLoading = false;
      notifyListeners();

      if (loginResponse['success'] != true) {
        return {
          'success': false,
          'code': 'LOGIN_AFTER_PIN_ERROR',
          'message':
              loginResponse['message'] ??
              AppLocalizations.t('invalid_credentials'),
        };
      }

      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'code': 'SERVER_ERROR',
        'message': AppLocalizations.t('set_pin_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String telephone,
    required String pin,
  }) async {
    final response = await ApiService.post(
      endpoint: AppConstants.login,
      data: {'telephone': telephone, 'pin': pin},
    );

    if (response['success'] == true) {
      final data = response['data'];
      final String token = data['token'];
      final UserModel user = UserModel.fromJson(data['user']);

      // Persistence des données dans SharedPreferences
      await StorageManager.saveToken(token);
      await StorageManager.saveUser(user);

      return {'success': true, 'message': response['message'], 'user': user};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }
}
