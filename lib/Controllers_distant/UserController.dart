import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:njangi/Models/Invitation.dart';
import 'package:njangi/Models/user_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/management/storage_manager.dart';

class UserController {
  static Future<List<RegisteredUser>> searchUsersByPhone(String query) async {
    final phoneDigits = query.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.isEmpty) return const [];

    try {
      final response = await ApiService.dio.get(
        'utilisateurs',
        queryParameters: {'search': phoneDigits},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        debugPrint('[API] User search returned an invalid response: $body');
        throw const FormatException('Invalid users search response');
      }

      final page = body['data'];
      final rows = page is Map ? page['data'] : page;
      if (rows is! List) {
        debugPrint('[API] User search response has no user list: $body');
        throw const FormatException('User list missing from search response');
      }

      return rows
          .whereType<Map>()
          .map((row) {
            final user = Map<String, dynamic>.from(row);
            final firstName = user['prenom']?.toString().trim() ?? '';
            final lastName = user['nom']?.toString().trim() ?? '';
            final name = [
              firstName,
              lastName,
            ].where((part) => part.isNotEmpty).join(' ');
            return RegisteredUser(
              id: user['id']?.toString() ?? '',
              name: name.isEmpty ? user['telephone']?.toString() ?? '' : name,
              phone: user['telephone']?.toString() ?? '',
              tokenFirebase: user['token_firebase']?.toString(),
            );
          })
          .where((user) => user.id.isNotEmpty && user.phone.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      ApiService.logServerError(error);
      rethrow;
    }
  }

  static Future<RegisteredUser?> getByPhone(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) return null;

    try {
      final response = await ApiService.dio.get(
        'utilisateurs',
        queryParameters: {'telephone': normalizedPhone},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        debugPrint(
          '[API] Exact user lookup returned an invalid response: $body',
        );
        throw const FormatException('Invalid exact user lookup response');
      }

      final page = body['data'];
      final rows = page is Map ? page['data'] : page;
      if (rows is! List) {
        debugPrint('[API] Exact user lookup has no user list: $body');
        throw const FormatException('User list missing from exact lookup');
      }

      for (final row in rows.whereType<Map>()) {
        final user = Map<String, dynamic>.from(row);
        if (user['telephone']?.toString() != normalizedPhone) continue;

        final firstName = user['prenom']?.toString().trim() ?? '';
        final lastName = user['nom']?.toString().trim() ?? '';
        final name = [
          firstName,
          lastName,
        ].where((part) => part.isNotEmpty).join(' ');
        return RegisteredUser(
          id: user['id']?.toString() ?? '',
          name: name.isEmpty ? normalizedPhone : name,
          phone: normalizedPhone,
          tokenFirebase: user['token_firebase']?.toString(),
        );
      }
      return null;
    } on DioException catch (error) {
      ApiService.logServerError(error);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateFirebaseToken({
    required String userId,
    required String firebaseToken,
  }) async {
    try {
      final response = await ApiService.dio.patch(
        'auth/firebase-token/$userId',
        data: {'token_firebase': firebaseToken},
      );
      final body = response.data;

      if (body is! Map || body['success'] != true) {
        debugPrint(
          '[API] Firebase token update returned failure: '
          '${body is Map ? body : response.data}',
        );
        return {
          'success': false,
          'message': AppLocalizations.t('firebase_token_update_error'),
        };
      }

      return {
        'success': true,
        'message': AppLocalizations.t('firebase_token_update_success'),
        'data': body['data'],
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'firebase_token_update_error',
        ),
      };
    } catch (error) {
      debugPrint('[API] Firebase token update failed unexpectedly: $error');
      return {
        'success': false,
        'message': AppLocalizations.t('firebase_token_update_error'),
      };
    }
  }

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
        'message': AppLocalizations.t('profile_update_success'),
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
