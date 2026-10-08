class AppConstants {
  static const String appName = 'NJANGI';
  static const String slogan = ' ';
  static const String appVersion = '15.0';

  static const String baseUrlProd = 'http://62.169.27.128:8000/api/';
  static const String baseUrlDev = 'http://62.169.27.128:8001/api/';
  static const String baseUrl = baseUrlDev;
  static String get imageBaseUrl => baseUrl.replaceFirst('/api/', '/storage/');

  // Endpoints Auth
  static const String sendOtp = 'auth/send-otp';
  static const String register = 'auth/register';
  static const String setPin = 'auth/set-pin';
  static const String login = 'auth/login';
  static const String verifyLoginOtp = 'auth/verify-login-otp';
  static const String verifyResetOtp = 'auth/verify-reset-otp';
  static const String resetPin = 'auth/reset-pin';
  static const String refreshToken = 'auth/refresh-token';

  // Groupes
  static const String groupes = 'groupes';
  static const String cycles = 'cycles';
  static const String utilisateurs = 'utilisateurs';

  // Invitations (domaine à confirmer avec le backend)
  static const String inviteBaseUrl = 'https://njangi.app/join/';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.njangi';

  // Storage Keys
  static const String userToken = 'user_token';
  static const String userData = 'user_data';
  static const String languageCode = 'language_code';
  static const String countryCode = 'country_code';
}
