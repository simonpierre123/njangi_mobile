import 'dart:convert';

class Notification {
  const Notification({
    this.id,
    required this.userId,
    required this.scope,
    this.groupId,
    this.cycleId,
    required this.title,
    required this.description,
    required this.eventType,
    this.notifiableType,
    this.notifiableId,
    this.payload,
    this.isRead = false,
    this.pushSent = false,
    this.active = '1',
    this.expiresAt,
    this.createdAt,
  });

  final String? id;
  final String userId;
  final String scope;
  final String? groupId;
  final String? cycleId;
  final String title;
  final String description;
  final String eventType;
  final String? notifiableType;
  final String? notifiableId;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final bool pushSent;
  final String active;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  bool get isInvitation =>
      eventType == 'INVITATION_GROUPE' ||
      eventType == 'INVITATION_PROCHAINS_CYCLES';

  bool get isUpcomingCycleInvitation =>
      eventType == 'INVITATION_PROCHAINS_CYCLES';

  bool get isCycleRuleNotification =>
      payload?['action']?.toString().startsWith('CYCLE_RULE') ?? false;

  bool get isActionable => isInvitation || isCycleRuleNotification;

  Notification copyWith({bool? isRead, bool? pushSent}) => Notification(
    id: id,
    userId: userId,
    scope: scope,
    groupId: groupId,
    cycleId: cycleId,
    title: title,
    description: description,
    eventType: eventType,
    notifiableType: notifiableType,
    notifiableId: notifiableId,
    payload: payload,
    isRead: isRead ?? this.isRead,
    pushSent: pushSent ?? this.pushSent,
    active: active,
    expiresAt: expiresAt,
    createdAt: createdAt,
  );

  Map<String, dynamic> toCreateJson() => {
    'utilisateur_id': userId,
    'portee': scope,
    'groupe_id': groupId,
    'cycle_id': cycleId,
    'titre': title,
    'description': description,
    'type_evenement': eventType,
    'notifiable_type': notifiableType,
    'notifiable_id': notifiableId,
    'payload': payload,
  };

  factory Notification.fromJson(Map<String, dynamic> json) {
    final payload = _decodePayload(json['payload']);
    return Notification(
      id: json['id']?.toString(),
      userId: json['utilisateur_id']?.toString() ?? '',
      scope: json['portee']?.toString() ?? 'UTILISATEUR',
      groupId:
          json['groupe_id']?.toString() ??
          payload?['groupe_id']?.toString() ??
          payload?['group_id']?.toString(),
      cycleId: json['cycle_id']?.toString() ?? payload?['cycle_id']?.toString(),
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventType: json['type_evenement']?.toString() ?? '',
      notifiableType: json['notifiable_type']?.toString(),
      notifiableId: json['notifiable_id']?.toString(),
      payload: payload,
      isRead: json['est_lu'] == true || json['est_lu']?.toString() == '1',
      pushSent:
          json['push_envoye'] == true || json['push_envoye']?.toString() == '1',
      active: json['active']?.toString() ?? '1',
      expiresAt: DateTime.tryParse(json['expire_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  factory Notification.fromFcmData(
    Map<String, dynamic> data, {
    required String userId,
    String title = '',
    String description = '',
  }) {
    final payload = _decodePayload(data['payload']) ?? <String, dynamic>{};
    for (final key in ['invitation_id', 'groupe_id', 'cycle_id']) {
      final value = data[key];
      if (value != null) payload.putIfAbsent(key, () => value.toString());
    }

    return Notification.fromJson({
      'id': data['notification_id'],
      'utilisateur_id': userId,
      'portee': data['portee'] ?? 'CYCLE',
      'groupe_id': data['groupe_id'],
      'cycle_id': data['cycle_id'],
      'titre': title,
      'description': description,
      'type_evenement': data['type_evenement'] ?? data['type'],
      'payload': payload,
    });
  }
}

Map<String, dynamic>? _decodePayload(dynamic rawPayload) {
  if (rawPayload is Map) return Map<String, dynamic>.from(rawPayload);
  if (rawPayload is! String || rawPayload.isEmpty) return null;

  try {
    final decoded = jsonDecode(rawPayload);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  } on FormatException {
    return null;
  }
}
