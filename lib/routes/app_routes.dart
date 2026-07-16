/// Noms de route centralisés. Toujours utiliser ces constantes plutôt
/// que des chaînes en dur, pour éviter les fautes de frappe entre écrans.
class AppRoutes {
  AppRoutes._();

  static const onboarding = '/';
  static const authLanding = '/auth';
  static const login = '/login'; // à venir (3 écrans de connexion)

  static const registerPhone = '/register/phone';
  static const verifyOtp = '/register/otp';
  static const phoneVerified = '/register/verified';
  static const createPin = '/register/pin/create';
  static const confirmPin = '/register/pin/confirm';

  static const comingSoon = '/coming-soon';
}