import 'package:dio/dio.dart';
import 'package:njangi/Models/user_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class UserController {
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiService.dio.put(
        'utilisateurs/$userId',
        data: data,
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      final userData = body['data'];
      print(body['message']);
      print(body['message']);
      print(body['message']);
      if (body['success'] != true || userData is! Map) {
        return {
          'success': false,
          'message':
              body['message'] ?? AppLocalizations.t('profile_update_error'),
        };
      }

      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      await StorageManager.saveUser(user);

      return {
        'success': true,
        'message':
            body['message'] ?? AppLocalizations.t('profile_update_success'),
        'user': user,
      };
    } on DioException catch (error) {
      final responseData = error.response?.data;
      return {
        'success': false,
        'message':
            responseData is Map
                ? responseData['message'] ??
                    AppLocalizations.t('profile_update_error')
                : AppLocalizations.t('profile_update_error'),
      };
    } catch (error) {
      return {
        'success': false,
        'message': AppLocalizations.t('profile_update_error'),
      };
    }
  }
}
