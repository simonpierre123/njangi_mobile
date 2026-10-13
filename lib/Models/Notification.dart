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
    final rawPayload = json['payload'];
    return Notification(
      id: json['id']?.toString(),
      userId: json['utilisateur_id']?.toString() ?? '',
      scope: json['portee']?.toString() ?? 'UTILISATEUR',
      groupId: json['groupe_id']?.toString(),
      cycleId: json['cycle_id']?.toString(),
      title: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventType: json['type_evenement']?.toString() ?? '',
      notifiableType: json['notifiable_type']?.toString(),
      notifiableId: json['notifiable_id']?.toString(),
      payload: rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : null,
      isRead: json['est_lu'] == true || json['est_lu']?.toString() == '1',
      pushSent:
          json['push_envoye'] == true || json['push_envoye']?.toString() == '1',
      active: json['active']?.toString() ?? '1',
      expiresAt: DateTime.tryParse(json['expire_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
