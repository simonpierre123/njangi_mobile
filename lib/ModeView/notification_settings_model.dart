/// Modèles pour l'écran "Notifications" (Profil).
///
/// TODO (Njoya) : à remplacer par les vraies préférences utilisateur
/// une fois l'API branchée — alimentés pour l'instant par
/// datasource/notification_settings_mock_datasource.dart.

class NotificationToggleItem {
  const NotificationToggleItem({required this.key, required this.label, required this.value});

  final String key; // identifiant stable (utilisé comme clé d'état)
  final String label;
  final bool value;
}

class NotificationSection {
  const NotificationSection({required this.title, required this.items});

  final String title;
  final List<NotificationToggleItem> items;
}