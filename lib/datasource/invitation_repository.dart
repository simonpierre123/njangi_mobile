import 'dart:convert' show jsonEncode;
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../api/firebase_api.dart';
import '../Controllers_distant/CycleController.dart';
import '../Controllers_distant/MembreGroupeCycleController.dart';
import '../Controllers_distant/UserController.dart';
import '../Models/Invitation.dart';
import '../localization/app_localizations.dart';

/// Point d'entrée unique des invitations ; remplacer [instance] par
/// l'implémentation API (Laravel) quand le backend sera prêt.
abstract class InvitationRepository {
  static InvitationRepository instance = ApiInvitationRepository();

  Future<List<RegisteredUser>> searchUsersByPhone(String query);

  /// Crée l'invitation (rôle INVITE) pour un utilisateur existant.
  Future<Invitation> inviteUser({
    required String groupId,
    required String groupName,
    String? cycleId,
    required RegisteredUser user,
  });

  Future<Invitation> invitePhone({
    required String groupId,
    required String groupName,
    String? cycleId,
    required String phone,
  });

  /// Jeton d'adhésion partagé par lien ou QR code.
  Future<Invitation> createJoinToken({
    required String groupId,
    required InvitationMethod method,
  });

  Future<List<PhoneContact>> loadDeviceContacts();

  Future<List<Invitation>> inviteContacts({
    required String groupId,
    required String groupName,
    String? cycleId,
    required List<PhoneContact> contacts,
  });

  /// Simulation uniquement : quelqu'un ouvre le lien ou scanne le QR code.
  Future<Invitation> simulateJoin(Invitation invitation);

  Future<void> revoke(String invitationId);
}

class SimulatedInvitationRepository implements InvitationRepository {
  SimulatedInvitationRepository({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;
  final Random _random = Random.secure();
  int _sequence = 0;
  int _joinCount = 0;

  static const registry = [
    RegisteredUser(id: 'u-1', name: 'Marie Ndzié', phone: '+237690000001'),
    RegisteredUser(id: 'u-2', name: 'Jean Dupont', phone: '+237677000002'),
    RegisteredUser(id: 'u-3', name: 'Alice Mbarga', phone: '+237655000003'),
    RegisteredUser(id: 'u-4', name: 'Thomas Bella', phone: '+237699000004'),
    RegisteredUser(id: 'u-5', name: 'Sandrine Fotso', phone: '+237670000005'),
  ];

  static const _contacts = [
    PhoneContact(name: 'Paul Essomba', phone: '+237691112233'),
    PhoneContact(name: 'Carine Tchamba', phone: '+237677445566'),
    PhoneContact(name: 'Michel Kamga', phone: '+237655778899'),
    PhoneContact(name: 'Nadège Owona', phone: '+237699001122'),
    PhoneContact(name: 'Brice Nkoulou', phone: '+237670334455'),
    PhoneContact(name: 'Estelle Manga', phone: '+237681556677'),
  ];

  static String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  String _newId() => 'inv-${++_sequence}';

  String _newToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      16,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  @override
  Future<List<RegisteredUser>> searchUsersByPhone(String query) async {
    await Future<void>.delayed(latency);
    final digits = _digits(query);
    if (digits.isEmpty) return const [];
    return registry
        .where((user) => _digits(user.phone).contains(digits))
        .toList(growable: false);
  }

  @override
  Future<Invitation> inviteUser({
    required String groupId,
    required String groupName,
    String? cycleId,
    required RegisteredUser user,
  }) async {
    await Future<void>.delayed(latency);
    return Invitation(
      id: _newId(),
      groupId: groupId,
      method: InvitationMethod.phone,
      displayName: user.name,
      phone: user.phone,
    );
  }

  @override
  Future<Invitation> invitePhone({
    required String groupId,
    required String groupName,
    String? cycleId,
    required String phone,
  }) async {
    await Future<void>.delayed(latency);
    return Invitation(
      id: _newId(),
      groupId: groupId,
      method: InvitationMethod.phone,
      displayName: phone,
      phone: phone,
      pushSent: false,
    );
  }

  @override
  Future<Invitation> createJoinToken({
    required String groupId,
    required InvitationMethod method,
  }) async {
    await Future<void>.delayed(latency);
    return Invitation(
      id: _newId(),
      groupId: groupId,
      method: method,
      token: _newToken(),
    );
  }

  @override
  Future<List<PhoneContact>> loadDeviceContacts() async {
    await Future<void>.delayed(latency);
    return SimulatedInvitationRepository._contacts;
  }

  @override
  Future<List<Invitation>> inviteContacts({
    required String groupId,
    required String groupName,
    String? cycleId,
    required List<PhoneContact> contacts,
  }) async {
    await Future<void>.delayed(latency);
    return [
      for (final contact in contacts)
        Invitation(
          id: _newId(),
          groupId: groupId,
          method: InvitationMethod.contact,
          token: _newToken(),
          displayName: contact.name,
          phone: contact.phone,
        ),
    ];
  }

  @override
  Future<Invitation> simulateJoin(Invitation invitation) async {
    await Future<void>.delayed(latency);
    final user =
        SimulatedInvitationRepository.registry[_joinCount++ %
            SimulatedInvitationRepository.registry.length];
    return invitation.copyWith(
      status: InvitationStatus.joined,
      displayName: user.name,
      phone: user.phone,
    );
  }

  @override
  Future<void> revoke(String invitationId) async {
    await Future<void>.delayed(latency);
  }
}

class ApiInvitationRepository extends SimulatedInvitationRepository {
  ApiInvitationRepository();

  @override
  Future<List<RegisteredUser>> searchUsersByPhone(String query) =>
      UserController.searchUsersByPhone(query);

  @override
  Future<Invitation> inviteUser({
    required String groupId,
    required String groupName,
    String? cycleId,
    required RegisteredUser user,
  }) async {
    var stage = 'validation du destinataire';
    debugPrint(
      '[INVITATION] Début: groupId=$groupId '
      'cycleId=${cycleId ?? '(à déterminer)'} '
      'phoneSuffix=${user.phone.length > 4 ? user.phone.substring(user.phone.length - 4) : user.phone}',
    );
    try {
      if (user.id.isEmpty) {
        throw InviteFlowException(AppLocalizations.t('invite_user_not_found'));
      }
      debugPrint(
        '[INVITATION] Utilisateur trouvé: id=${user.id}, '
        'tokenFcmPresent=${user.tokenFirebase?.trim().isNotEmpty == true}.',
      );
      if (kDebugMode) {
        debugPrint(
          '[FCM][INVITATION] userId=${user.id} '
          'token_firebase=${user.tokenFirebase?.trim().isNotEmpty == true ? user.tokenFirebase : '(absent)'}.',
        );
      }

      stage = 'résolution du cycle';
      final targetCycleId = await _resolveCycleId(groupId, cycleId);

      stage = 'création de l\'invitation de cycle';
      final cycleInvitation =
          await MembreGroupeCycleController.createCycleInvitation(
            cycleId: targetCycleId,
            inviteeId: user.id,
          );
      if (cycleInvitation['success'] != true) {
        debugPrint('[INVITATION] Échec ($stage): $cycleInvitation');
        throw InviteFlowException(
          cycleInvitation['message']?.toString() ??
              AppLocalizations.t('invite_persist_error'),
        );
      }

      final invitationId = cycleInvitation['invitationId']?.toString();
      final invitationData = cycleInvitation['data'];
      final pushStatus =
          invitationData is Map
              ? invitationData['push_envoye'] ??
                  invitationData['push_sent'] ??
                  (invitationData['notification'] is Map
                      ? (invitationData['notification'] as Map)['push_envoye']
                      : null)
              : null;
      if (invitationId == null || invitationId.isEmpty) {
        throw InviteFlowException(AppLocalizations.t('invite_persist_error'));
      }
      var pushSent = false;
      final token = user.tokenFirebase?.trim();
      if (token != null && token.isNotEmpty) {
        final notificationBody = AppLocalizations.t(
          'invitation_notification_body',
          args: [groupName],
        );
        try {
          pushSent = await FirebaseApi().sendPushNotification(
            deviceToken: token,
            title: AppLocalizations.t('invitation_notification_title'),
            body: notificationBody,
            data: {
              'type_evenement': 'INVITATION_PROCHAINS_CYCLES',
              'portee': 'CYCLE',
              'screen': 'INVITATION_DETAILS',
              'notification_id': '',
              'invitation_id': invitationId,
              'groupe_id': groupId,
              'cycle_id': targetCycleId,
              'payload': jsonEncode({
                'screen': 'INVITATION_DETAILS',
                'invitation_id': invitationId,
                'groupe_id': groupId,
                'cycle_id': targetCycleId,
              }),
            },
          );
        } catch (error, stackTrace) {
          debugPrint('[FCM][INVITATION] Envoi direct échoué: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
      return Invitation(
        id: invitationId,
        groupId: groupId,
        method: InvitationMethod.phone,
        displayName: user.name,
        phone: user.phone,
        pushSent: pushSent,
      );
    } catch (error, stackTrace) {
      debugPrint('[INVITATION] Échec pendant $stage: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  bool? _parsePushStatus(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return switch (value.toLowerCase()) {
        '1' || 'true' => true,
        '0' || 'false' => false,
        _ => null,
      };
    }
    return null;
  }

  @override
  Future<Invitation> invitePhone({
    required String groupId,
    required String groupName,
    String? cycleId,
    required String phone,
  }) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      throw InviteFlowException(AppLocalizations.t('invite_persist_error'));
    }

    final targetCycleId = await _resolveCycleId(groupId, cycleId);
    final result = await MembreGroupeCycleController.createCycleInvitation(
      cycleId: targetCycleId,
      telephone: normalizedPhone,
    );
    if (result['success'] != true) {
      throw InviteFlowException(
        result['message']?.toString() ??
            AppLocalizations.t('invite_persist_error'),
      );
    }

    final invitationId = result['invitationId']?.toString();
    if (invitationId == null || invitationId.isEmpty) {
      throw InviteFlowException(AppLocalizations.t('invite_persist_error'));
    }
    return Invitation(
      id: invitationId,
      groupId: groupId,
      method: InvitationMethod.phone,
      displayName: normalizedPhone,
      phone: normalizedPhone,
      pushSent: false,
    );
  }

  Future<String> _resolveCycleId(String groupId, String? cycleId) async {
    if (cycleId != null && cycleId.isNotEmpty) return cycleId;

    final cycles = await CycleController.getForGroup(groupId);
    if (cycles == null || cycles.isEmpty) {
      throw InviteFlowException(AppLocalizations.t('invite_cycle_missing'));
    }
    final selectedCycle =
        cycles.where((cycle) {
          final status = cycle.status?.toUpperCase();
          return status == 'EN_COURS' || status == 'ACTIF';
        }).firstOrNull ??
        cycles.first;
    final targetCycleId = selectedCycle.id;
    if (targetCycleId == null || targetCycleId.isEmpty) {
      throw InviteFlowException(AppLocalizations.t('invite_cycle_missing'));
    }
    return targetCycleId;
  }

  @override
  Future<List<Invitation>> inviteContacts({
    required String groupId,
    required String groupName,
    String? cycleId,
    required List<PhoneContact> contacts,
  }) async {
    if (cycleId == null || cycleId.isEmpty) {
      throw InviteFlowException(AppLocalizations.t('invite_cycle_missing'));
    }

    final invitations = <Invitation>[];
    for (final contact in contacts) {
      final user = await UserController.getByPhone(contact.phone);
      if (user != null) {
        invitations.add(
          await inviteUser(
            groupId: groupId,
            groupName: groupName,
            cycleId: cycleId,
            user: user,
          ),
        );
        continue;
      }

      final result = await MembreGroupeCycleController.createCycleInvitation(
        cycleId: cycleId,
        telephone: contact.phone,
      );
      if (result['success'] != true) {
        throw InviteFlowException(
          result['message']?.toString() ??
              AppLocalizations.t('invite_persist_error'),
        );
      }
      final invitationId = result['invitationId']?.toString();
      if (invitationId == null || invitationId.isEmpty) {
        throw InviteFlowException(AppLocalizations.t('invite_persist_error'));
      }
      invitations.add(
        Invitation(
          id: invitationId,
          groupId: groupId,
          method: InvitationMethod.contact,
          displayName: contact.name,
          phone: contact.phone,
          pushSent: false,
        ),
      );
    }
    return invitations;
  }

  @override
  Future<Invitation> createJoinToken({
    required String groupId,
    required InvitationMethod method,
  }) async {
    await Future<void>.delayed(latency);
    return Invitation(
      id: _newId(),
      groupId: groupId,
      method: method,
      token: _newToken(),
    );
  }

  @override
  Future<List<PhoneContact>> loadDeviceContacts() async {
    await Future<void>.delayed(latency);
    return SimulatedInvitationRepository._contacts;
  }

  @override
  Future<Invitation> simulateJoin(Invitation invitation) async {
    await Future<void>.delayed(latency);
    final user =
        SimulatedInvitationRepository.registry[_joinCount++ %
            SimulatedInvitationRepository.registry.length];
    return invitation.copyWith(
      status: InvitationStatus.joined,
      displayName: user.name,
      phone: user.phone,
    );
  }

  @override
  Future<void> revoke(String invitationId) async {
    await Future<void>.delayed(latency);
  }
}

class InviteFlowException implements Exception {
  const InviteFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}
