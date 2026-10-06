import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:njangi/Models/user_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/management/storage_manager.dart';

// class UserController {
//   static Future<Map<String, dynamic>> updateProfile({
//     required String userId,
//     required Map<String, dynamic> data,
//     File? photo,
//   }) async {
//     try {
//       Object requestData = data;
//       Options? options;
//       if (photo != null) {
//         requestData = FormData.fromMap({
//           ...data,
//           'photo': await MultipartFile.fromFile(photo.path),
//         });
//         options = Options(contentType: Headers.multipartFormDataContentType);
//       }

//       final response = await ApiService.dio.put(
//         'utilisateurs/$userId',
//         data: requestData,
//         options: options,
//       );
//       final body = Map<String, dynamic>.from(response.data as Map);
//       final userData = body['data'];
//       print(body['message']);
//       print(body['message']);
//       print(body['message']);
//       if (body['success'] != true || userData is! Map) {
//         return {
//           'success': false,
//           'message':
//               body['message'] ?? AppLocalizations.t('profile_update_error'),
//         };
//       }

//       final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
//       await StorageManager.saveUser(user);

//       return {
//         'success': true,
//         'message':
//             body['message'] ?? AppLocalizations.t('profile_update_success'),
//         'user': user,
//       };
//     } on DioException catch (error) {
//       final responseData = error.response?.data;
//       return {
//         'success': false,
//         'message':
//             responseData is Map
//                 ? responseData['message'] ??
//                     AppLocalizations.t('profile_update_error')
//                 : AppLocalizations.t('profile_update_error'),
//       };
//     } catch (error) {
//       return {
//         'success': false,
//         'message': AppLocalizations.t('profile_update_error'),
//       };
//     }
//   }
// }
class UserController {
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
    File? photo,
    Map<String, File> documents = const {},
  }) async {
    try {
      // 1. On prépare la Map avec le Method Spoofing pour Laravel
      final Map<String, dynamic> payload = {
        ...data,
        '_method':
            'PUT', // Permet à Laravel d'interpréter la requête comme du PUT
      };

      if (photo != null) {
        payload['photo'] = await MultipartFile.fromFile(
          photo.path,
          filename: photo.uri.pathSegments.last,
        );
      }
      for (final entry in documents.entries) {
        payload[entry.key] = await MultipartFile.fromFile(
          entry.value.path,
          filename: entry.value.uri.pathSegments.last,
        );
      }

      // 2. Transformer en FormData
      final formData = FormData.fromMap(payload);

      // 3. Envoyer en POST (Dio gèrera le bon 'content-type' multipart)
      final response = await ApiService.dio.post(
        'utilisateurs/$userId',
        data: formData,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final userData = body['data'];

      if (body['success'] != true || userData is! Map) {
        final code = body['code']?.toString();
        debugPrint(
          '[API] POST ${response.requestOptions.uri} returned failure '
          '(status: ${response.statusCode}, code: $code, body: $body)',
        );
        return {
          'success': false,
          'message': ApiService.localizedMessageForCode(
            code,
            fallbackKey: 'profile_update_error',
          ),
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
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'profile_update_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] PUT /utilisateurs/$userId failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('profile_update_error'),
      };
    }
  }
}
