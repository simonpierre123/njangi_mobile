class AppConstants {
  static const String appName = 'NJANGI';
  static const String slogan = ' ';
  static const String appVersion = '15.0';

  static const String baseUrlProd = 'http://62.169.27.128:8000/api/';
  static const String baseUrlDev = 'http://62.169.27.128:8001/api/';
  static const String baseUrl = baseUrlDev;
  static const String imageBaseUrl = 'http://109.199.117.169:8500/storage/';

  // Endpoints Auth
  static const String sendOtp = 'auth/send-otp';
  static const String register = 'auth/register';
  static const String setPin = 'auth/set-pin';
  static const String login = 'auth/login';
  static const String refreshToken = 'auth/refresh-token';

  // Storage Keys
  static const String userToken = 'user_token';
  static const String userData = 'user_data';
  static const String languageCode = 'language_code';
  static const String countryCode = 'country_code';
}
