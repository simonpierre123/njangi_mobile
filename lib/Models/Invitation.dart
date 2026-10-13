import '../utils/app_constants.dart';

enum InvitationMethod { link, qr, phone, contact }

/// pending = rôle INVITE (groupe masqué chez l'invité), joined = rôle MEMBRE.
enum InvitationStatus { pending, joined }

/// Utilisateur trouvé par la recherche de numéro dans le système.
class RegisteredUser {
  const RegisteredUser({
    required this.id,
    required this.name,
    required this.phone,
    this.tokenFirebase,
  });

  final String id;
  final String name;
  final String phone;
  final String? tokenFirebase;
}

class PhoneContact {
  const PhoneContact({required this.name, required this.phone});

  final String name;
  final String phone;
}

class Invitation {
  const Invitation({
    required this.id,
    required this.groupId,
    required this.method,
    this.status = InvitationStatus.pending,
    this.token,
    this.displayName,
    this.phone,
    this.pushSent = true,
  });

  final String id;
  final String groupId;
  final InvitationMethod method;
  final InvitationStatus status;
  final String? token;
  final String? displayName;
  final String? phone;
  final bool pushSent;

  String? get link =>
      token == null ? null : '${AppConstants.inviteBaseUrl}$token';

  Invitation copyWith({
    InvitationStatus? status,
    String? displayName,
    String? phone,
  }) {
    return Invitation(
      id: id,
      groupId: groupId,
      method: method,
      status: status ?? this.status,
      token: token,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      pushSent: pushSent,
    );
  }
}
