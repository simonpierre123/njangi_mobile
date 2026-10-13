import 'dart:math';

import 'package:flutter/foundation.dart';
import '../Controllers_distant/CycleController.dart';
import '../Controllers_distant/MembreGroupeController.dart';
import '../Controllers_distant/MembreGroupeCycleController.dart';
import '../Controllers_distant/NotificationController.dart';
import '../Controllers_distant/UserController.dart';
import '../Models/Invitation.dart';
import '../Models/Notification.dart';
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

  /// Jeton d'adhésion partagé par lien ou QR code.
  Future<Invitation> createJoinToken({
    required String groupId,
    required InvitationMethod method,
  });

  Future<List<PhoneContact>> loadDeviceContacts();

  Future<List<Invitation>> inviteContacts({
    required String groupId,
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
    var stage = 'recherche exacte du téléphone';
    debugPrint(
      '[INVITATION] Début: groupId=$groupId '
      'cycleId=${cycleId ?? '(à déterminer)'} '
      'phoneSuffix=${user.phone.length > 4 ? user.phone.substring(user.phone.length - 4) : user.phone}',
    );
    try {
      final invitee = await UserController.getByPhone(user.phone);
      if (invitee == null || invitee.id.isEmpty) {
        throw InviteFlowException(AppLocalizations.t('invite_user_not_found'));
      }
      debugPrint(
        '[INVITATION] Utilisateur trouvé: id=${invitee.id}, '
        'tokenFcmPresent=${invitee.tokenFirebase?.trim().isNotEmpty == true}.',
      );

      stage = 'résolution du cycle';
      var targetCycleId = cycleId;
      if (targetCycleId == null || targetCycleId.isEmpty) {
        final cycles = await CycleController.getForGroup(groupId);
        if (cycles == null || cycles.isEmpty) {
          throw InviteFlowException(AppLocalizations.t('invite_cycle_missing'));
        }
        targetCycleId =
            cycles
                .where((cycle) {
                  final status = cycle.status?.toUpperCase();
                  return status == 'EN_COURS' || status == 'ACTIF';
                })
                .firstOrNull
                ?.id ??
            cycles.first.id;
        if (targetCycleId == null || targetCycleId.isEmpty) {
          throw InviteFlowException(AppLocalizations.t('invite_cycle_missing'));
        }
      }

      stage = 'ajout au groupe';
      final groupMembership = await MembreGroupeController.addUserAsInvite(
        groupeId: groupId,
        utilisateurId: invitee.id,
      );
      if (groupMembership['success'] != true) {
        debugPrint('[INVITATION] Échec ($stage): $groupMembership');
        throw InviteFlowException(
          groupMembership['message']?.toString() ??
              AppLocalizations.t('invite_persist_error'),
        );
      }

      stage = 'ajout au cycle';
      final cycleMembership = await MembreGroupeCycleController.addUserAsInvite(
        cycleId: targetCycleId,
        utilisateurId: invitee.id,
      );
      if (cycleMembership['success'] != true) {
        debugPrint('[INVITATION] Échec ($stage): $cycleMembership');
        throw InviteFlowException(
          cycleMembership['message']?.toString() ??
              AppLocalizations.t('invite_persist_error'),
        );
      }

      stage = 'création notification et envoi push';
      final notificationResult = await NotificationController.createInvitation(
        userId: invitee.id,
        tokenFirebase: invitee.tokenFirebase,
        groupId: groupId,
        cycleId: targetCycleId,
        groupName: groupName,
      );
      if (notificationResult['success'] != true) {
        debugPrint('[INVITATION] Échec ($stage): $notificationResult');
        throw InviteFlowException(
          notificationResult['message']?.toString() ??
              AppLocalizations.t('invite_notification_error'),
        );
      }

      final notification = notificationResult['notification'] as Notification;
      return Invitation(
        id: notification.id ?? _newId(),
        groupId: groupId,
        method: InvitationMethod.phone,
        displayName: invitee.name,
        phone: invitee.phone,
        pushSent: notification.pushSent,
      );
    } catch (error, stackTrace) {
      debugPrint('[INVITATION] Échec pendant $stage: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
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

class InviteFlowException implements Exception {
  const InviteFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}
