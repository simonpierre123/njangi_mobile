/// Noms de route centralisés. Toujours utiliser ces constantes plutôt
/// que des chaînes en dur, pour éviter les fautes de frappe entre écrans.
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/';
  static const authLanding = '/auth';

  static const registerPhone = '/register/phone';
  static const registerOtp = '/register/otp';
  static const createPin = '/register/pin/create';
  static const confirmPin = '/register/pin/confirm';

  static const loginPhone = '/login/phone';
  static const loginOtp = '/login/otp';
  static const enterPin = '/login/pin/enter';

  // Écran de succès partagé (inscription ET connexion) — l'argument
  // passé est le nom de la route suivante (String).
  static const phoneVerified = '/verified';

  static const pinCreated = '/register/pin/created';
  static const welcome = '/register/welcome';

  // Shell de l'accueil (Accueil/Notifications/Profil) — 1 seule route.
  static const home = '/home';

  // Shell de l'espace communauté (Tableau de Bord/Trésorerie/Membres/
  // Profil) — 1 SEULE route pour ce qui prenait 5 routes avant
  // (communityAdmin/communityMember/communityTreasury/
  // communityMembersAdmin/communityMembers). La bascule admin/membre se
  // fait à l'intérieur du shell selon CommunityModel.role.
  static const communityShell = '/community';

  // Profil n'est plus une route à part — c'est un onglet embarqué dans
  // HomeShell ET CommunityShell (même widget, deux shells). Seules ses
  // sous-pages de consultation/édition restent de vraies routes poussées.
  static const myProfile = '/profile/me';
  static const editProfile = '/profile/edit';
  static const security = '/profile/security';
  static const notifications = '/profile/notifications';
  static const preferences = '/profile/preferences';

  // Créer une communauté (5 étapes prévues, 1 et 2 construites pour
  // l'instant). Le brouillon (CommunityDraft) est porté d'étape en
  // étape via les arguments de route.
  static const createCommunityStep1 = '/community/create/1';
  static const createCommunityStep2 = '/community/create/2';
  static const createCommunityStep3 = '/community/create/3';
  static const createCommunityStep4 = '/community/create/4';
  static const createCommunityStep5 = '/community/create/5';

  static const contributionDetail = '/community/contribution/detail';

  static const financialSummary = '/community/report/summary';
  static const detailedReport = '/community/report/detailed';

  static const cycleCompleted = '/community/cycle-completed';

  static const kycIntro = '/kyc/intro';
  static const kycDocumentType = '/kyc/document-type';
  static const kycCapture = '/kyc/capture';

  static const comingSoon = '/coming-soon';
}