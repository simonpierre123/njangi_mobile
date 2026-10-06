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
      if (response['success'] != true) {
        final code = response['code']?.toString();
        response['translated_message'] =
            code == null
                ? AppLocalizations.t('otp_send_error')
                : ApiService.localizedMessageForCode(
                  code,
                  fallbackKey: 'otp_send_error',
                );
      }

      return response;
    } catch (e) {
      ApiService.logUnexpectedError('AuthController.sendOtp', e);
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
      ApiService.logUnexpectedError('AuthController.register', e);
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'code': 'UNKNOWN_ERROR',
        'message': AppLocalizations.t('register_error'),
      };
    }
  }

  Future<Map<String, dynamic>> verifyLoginOtp({
    required String telephone,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.verifyLoginOtp,
        data: {'telephone': telephone, 'code': code},
      );
      final responseData = response['data'];
      final data = responseData is Map ? responseData['data'] : null;

      if (response['success'] != true ||
          data is! Map ||
          data['has_pin'] is! bool ||
          (data['has_pin'] == false &&
              (data['reset_token'] is! String ||
                  (data['reset_token'] as String).isEmpty))) {
        return {
          'success': false,
          'message':
              response['message'] ??
              AppLocalizations.t('pin_status_unavailable'),
        };
      }

      return {
        'success': true,
        'has_pin': data['has_pin'],
        'reset_token': data['reset_token'],
        'message': response['message'],
      };
    } catch (error) {
      ApiService.logUnexpectedError('AuthController.verifyLoginOtp', error);
      return {'success': false, 'message': AppLocalizations.t('UNKNOWN_ERROR')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String telephone,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.verifyResetOtp,
        data: {'telephone': telephone, 'code': code},
      );
      final responseData = response['data'];
      final data = responseData is Map ? responseData['data'] : null;
      final resetToken = data is Map ? data['reset_token'] : null;

      if (response['success'] != true ||
          resetToken is! String ||
          resetToken.isEmpty) {
        return {
          'success': false,
          'message':
              response['message'] ??
              AppLocalizations.t('pin_status_unavailable'),
        };
      }

      return {'success': true, 'reset_token': resetToken};
    } catch (error) {
      ApiService.logUnexpectedError('AuthController.verifyResetOtp', error);
      return {'success': false, 'message': AppLocalizations.t('UNKNOWN_ERROR')};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resetPin({
    required String telephone,
    required String resetToken,
    required String pin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        endpoint: AppConstants.resetPin,
        data: {
          'telephone': telephone,
          'reset_token': resetToken,
          'pin': pin,
          'pin_confirmation': pin,
        },
      );

      return {
        'success': response['success'] == true,
        'message':
            response['message'] ??
            AppLocalizations.t(
              response['success'] == true
                  ? 'pin_reset_success'
                  : 'pin_reset_error',
            ),
      };
    } catch (error) {
      ApiService.logUnexpectedError('AuthController.resetPin', error);
      return {
        'success': false,
        'message': AppLocalizations.t('pin_reset_error'),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
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
      ApiService.logUnexpectedError('AuthController.setPin', e);
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
