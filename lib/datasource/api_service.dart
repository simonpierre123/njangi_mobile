import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:njangi/utils/management/storage_manager.dart';
import '../localization/app_localizations.dart';
import '../utils/app_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static void initializeInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Gestion de l'expiration de token (401) et auto-refresh
          final nonRefreshableAuthEndpoints = [
            AppConstants.login,
            AppConstants.sendOtp,
            AppConstants.register,
            AppConstants.verifyLoginOtp,
            AppConstants.verifyResetOtp,
            AppConstants.resetPin,
          ];
          final isNonRefreshableAuthRequest = nonRefreshableAuthEndpoints.any(
            error.requestOptions.path.contains,
          );
          if (error.response?.statusCode == 401 &&
              !isNonRefreshableAuthRequest) {
            bool refreshed = await _refreshToken();
            if (refreshed) {
              final newOptions = error.requestOptions;
              final newToken = await StorageManager.getToken();

              newOptions.headers['Authorization'] = 'Bearer $newToken';

              try {
                final response = await dio.fetch(newOptions);
                return handler.resolve(response);
              } on DioException catch (e) {
                return handler.next(e);
              }
            } else {
              await StorageManager.logout();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static void logServerError(DioException error) {
    debugPrint(
      '[API] ${error.requestOptions.method} ${error.requestOptions.uri} '
      'failed (status: ${error.response?.statusCode ?? 'network'}): '
      '${error.response?.data ?? error.message}',
    );
  }

  static void logUnexpectedError(String operation, Object error) {
    debugPrint('[API] $operation failed unexpectedly: $error');
  }

  static String localizedMessageForCode(
    String? code, {
    String fallbackKey = 'UNKNOWN_ERROR',
  }) {
    if (code != null && code.isNotEmpty) {
      final translated = AppLocalizations.t(code);
      if (translated != code) return translated;
    }
    return AppLocalizations.t(fallbackKey);
  }

  static String localizedErrorMessage(
    DioException error, {
    String fallbackKey = 'UNKNOWN_ERROR',
  }) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final code = responseData['code']?.toString();
      if (code != null && code.isNotEmpty) {
        final translated = AppLocalizations.t(code);
        if (translated != code) return translated;
      }
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == null) return AppLocalizations.t('NETWORK_ERROR');
    if (statusCode == 401) return AppLocalizations.t('INVALID_CREDENTIALS');
    if (statusCode == 403) return AppLocalizations.t('FORBIDDEN_ERROR');
    if (statusCode == 404) return AppLocalizations.t('NOT_FOUND_ERROR');
    if (statusCode == 422 || statusCode == 400) {
      return AppLocalizations.t('VALIDATION_ERROR');
    }
    if (statusCode == 429) return AppLocalizations.t('TOO_MANY_ATTEMPTS');
    if (statusCode >= 500) return AppLocalizations.t('SERVER_ERROR');
    return AppLocalizations.t(fallbackKey);
  }

  static Future<bool> _refreshToken() async {
    try {
      final token = await StorageManager.getToken();
      if (token == null) return false;

      final response = await dio.post(
        AppConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final newToken = response.data['token'];
        await StorageManager.saveToken(newToken);
        return true;
      }
    } catch (e) {
      debugPrint('Refresh token failed: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(endpoint, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map && responseData['success'] == false) {
          final code = responseData['code']?.toString();
          debugPrint(
            '[API] POST ${response.requestOptions.uri} returned failure '
            '(status: ${response.statusCode}, code: $code, body: $responseData)',
          );
          return {
            'success': false,
            'message': localizedMessageForCode(code),
            'data': responseData,
            if (code != null) 'code': code,
          };
        }
        return {
          'success': true,
          'message':
              responseData is Map
                  ? responseData['message'] ??
                      AppLocalizations.t('request_success')
                  : AppLocalizations.t('request_success'),
          'data': responseData,
        };
      } else {
        debugPrint(
          '[API] POST ${response.requestOptions.uri} failed '
          '(status: ${response.statusCode}, body: ${response.data})',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('SERVER_ERROR'),
        };
      }
    } on DioException catch (error) {
      logServerError(error);
      final responseData = error.response?.data;
      return {
        'success': false,
        'message': localizedErrorMessage(error),
        if (responseData is Map && responseData['code'] != null)
          'code': responseData['code'].toString(),
      };
    } catch (error) {
      logUnexpectedError('POST $endpoint', error);
      return {'success': false, 'message': AppLocalizations.t('UNKNOWN_ERROR')};
    }
  }
}
