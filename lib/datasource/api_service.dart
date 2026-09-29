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
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains(AppConstants.login)) {
            bool refreshed = await _refreshToken();
            if (refreshed) {
              final newPath = error.requestOptions.path;
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
        return {
          'success': true,
          'message': responseData['message'] ?? 'Succès',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': AppLocalizations.t('SERVER_ERROR'),
        };
      }
    } catch (e) {
      debugPrint('API Error: $e');

      String errorMessage = AppLocalizations.t('UNKNOWN_ERROR');

      if (e is DioException) {
        if (e.response?.statusCode == 429) {
          errorMessage =
              e.response?.data['message'] ??
              AppLocalizations.t('TOO_MANY_ATTEMPTS');
        } else if (e.response?.statusCode == 401) {
          errorMessage =
              e.response?.data['message'] ??
              AppLocalizations.t('INVALID_CREDENTIALS');
        } else if (e.response?.data is Map<String, dynamic>) {
          errorMessage =
              e.response?.data['message'] ??
              AppLocalizations.t('UNKNOWN_ERROR');
        }
      }

      return {'success': false, 'message': errorMessage};
    }
  }
}
