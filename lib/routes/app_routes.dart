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
  static const home = '/home';
  static const communityAdmin = '/community/admin';
  static const communityMember = '/community/member';
  static const communityTreasury = '/community/treasury';
  static const communityMembersAdmin = '/community/members/admin';
  static const communityMembers = '/community/members';

  static const comingSoon = '/coming-soon';
}