import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:njangi/ModeView/beneficiary_model.dart';
import 'package:njangi/datasource/api_service.dart';
import 'package:njangi/localization/app_localizations.dart';
import 'package:njangi/utils/app_constants.dart';

class CycleTontineTourController {
  static Future<Map<String, dynamic>> getForCycle(String cycleId) async {
    try {
      final response = await ApiService.dio.get(
        'cycles/$cycleId/tontine/tours',
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        debugPrint('[API] Tontine tours returned an invalid response: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_tontine_load_error'),
        };
      }

      return {
        'success': true,
        'entries': _parseEntries(body['data'] as List),
        'meta':
            body['meta'] is Map
                ? Map<String, dynamic>.from(body['meta'] as Map)
                : const <String, dynamic>{},
      };
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_tontine_load_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineTourController.getForCycle',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_tontine_load_error'),
      };
    }
  }

  static Future<Map<String, dynamic>> setOrder({
    required String cycleId,
    required List<PassageOrderEntry> entries,
  }) async {
    final memberIds = entries.map((entry) => entry.membershipId).toList();
    if (memberIds.isEmpty ||
        memberIds.any((id) => id == null || id.trim().isEmpty)) {
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_tontine_save_error'),
      };
    }

    try {
      final response = await ApiService.dio.put(
        'cycles/$cycleId/tontine/ordre',
        data: {'membre_ids': memberIds},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        debugPrint('[API] Tontine order returned an invalid response: $body');
        return {
          'success': false,
          'message': AppLocalizations.t('cycle_tontine_save_error'),
        };
      }

      return {'success': true, 'entries': _parseEntries(body['data'] as List)};
    } on DioException catch (error) {
      ApiService.logServerError(error);
      return {
        'success': false,
        'message': ApiService.localizedErrorMessage(
          error,
          fallbackKey: 'cycle_tontine_save_error',
        ),
      };
    } catch (error) {
      ApiService.logUnexpectedError(
        'CycleTontineTourController.setOrder',
        error,
      );
      return {
        'success': false,
        'message': AppLocalizations.t('cycle_tontine_save_error'),
      };
    }
  }

  static List<PassageOrderEntry> _parseEntries(List rows) {
    final entries = rows
      .whereType<Map>()
      .map((row) {
        final tour = Map<String, dynamic>.from(row);
        final beneficiary = _asMap(tour['beneficiaire']);
        final user = _asMap(beneficiary?['utilisateur']);
        final firstName = user?['prenom']?.toString().trim() ?? '';
        final lastName = user?['nom']?.toString().trim() ?? '';
        final fullName = [
          firstName,
          lastName,
        ].where((part) => part.isNotEmpty).join(' ');
        final storedName = beneficiary?['utilisateur_nom']?.toString().trim();
        final storedPhoto = user?['photo']?.toString().trim();
        final photoUrl =
            storedPhoto == null || storedPhoto.isEmpty
                ? null
                : storedPhoto.startsWith('http')
                ? storedPhoto
                : '${AppConstants.imageBaseUrl}${storedPhoto.replaceFirst(RegExp(r'^/+'), '')}';
        final name =
            fullName.isNotEmpty
                ? fullName
                : storedName != null && storedName.isNotEmpty
                ? storedName
                : beneficiary?['utilisateur_id']?.toString() ??
                    beneficiary?['id']?.toString() ??
                    '—';
        final status = tour['statut']?.toString().toUpperCase() ?? 'A_VENIR';
        final date = DateTime.tryParse(tour['date_echeance']?.toString() ?? '');
        final isPaid = status == 'PAYE';

        return PassageOrderEntry(
          membershipId:
              tour['beneficiaire_membre_id']?.toString() ??
              beneficiary?['id']?.toString(),
          order: _toInt(tour['ordre']) ?? 0,
          name: name,
          photoUrl: photoUrl,
          statusLabel: _statusLabel(isPaid),
          dateBadge: _dateBadge(date),
          isCurrent: false,
          isPaid: isPaid,
        );
      })
      .toList(growable: false)..sort((a, b) => a.order.compareTo(b.order));

    final currentIndex = entries.indexWhere((entry) => !entry.isPaid);
    return [
      for (var index = 0; index < entries.length; index++)
        entries[index].copyWith(isCurrent: index == currentIndex),
    ];
  }

  static Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static int? _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  static String _statusLabel(bool isPaid) =>
      isPaid
          ? (AppLocalizations.locale.value == 'fr' ? 'Payé' : 'Paid')
          : (AppLocalizations.locale.value == 'fr' ? 'À venir' : 'Upcoming');

  static String _dateBadge(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
