import 'package:image_picker/image_picker.dart';

/// Utilitaire partagé de sélection d'image — un seul point d'accès à
/// [ImagePicker] pour toute l'app (création de communauté, cotisation,
/// décaissement, profil, KYC), plutôt que de réinstancier le picker à
/// chaque endroit.
class MediaPicker {
  MediaPicker._();

  static final _picker = ImagePicker();

  /// Retourne le fichier choisi, ou null si l'utilisateur a annulé.
  static Future<XFile?> pickFromCamera() {
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
  }

  static Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  }
}