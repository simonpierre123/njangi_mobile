import 'dart:math';

import '../Controllers_distant/UserController.dart';
import '../Models/Invitation.dart';

/// Point d'entrée unique des invitations ; remplacer [instance] par
/// l'implémentation API (Laravel) quand le backend sera prêt.
abstract class InvitationRepository {
  static InvitationRepository instance = SimulatedInvitationRepository();

  Future<List<RegisteredUser>> searchUsersByPhone(String query);

  /// Crée l'invitation (rôle INVITE) pour un utilisateur existant.
  Future<Invitation> inviteUser({
    required String groupId,
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

  String _newId() => 'inv-${++_sequence}';

  String _newToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      16,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  @override
  Future<List<RegisteredUser>> searchUsersByPhone(String query) =>
      UserController.searchUsersByPhone(query);

  @override
  Future<Invitation> inviteUser({
    required String groupId,
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
    return _contacts;
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
    final user = registry[_joinCount++ % registry.length];
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
