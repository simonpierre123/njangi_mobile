import '../Models/create_community_model.dart';
import '../utils/app_colors.dart';

/// Données mock des invitations déjà envoyées, en attendant l'API.
///
/// NB : aucune couleur exacte n'a été fournie pour les avatars "ML"/
/// "JD" — approximées avec des tokens déjà en place (tagMintBg/
/// primaryDark, warningBg/warningText). À ajuster si des hex précis
/// sont donnés.
class CreateCommunityMockDatasource {
  CreateCommunityMockDatasource._();

  static const initialInvites = [
    InvitedMember(
      name: 'Marie L.',
      phone: '+237 6XX XX XX XX',
      initials: 'ML',
      avatarBg: AppColors.tagMintBg,
      avatarColor: AppColors.primaryDark,
    ),
    InvitedMember(
      name: 'Jean D.',
      phone: '+237 6XX XX XX XX',
      initials: 'JD',
      avatarBg: AppColors.warningBg,
      avatarColor: AppColors.warningText,
    ),
  ];
}