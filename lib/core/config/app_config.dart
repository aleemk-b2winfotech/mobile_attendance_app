final class AppConfig {
  AppConfig._();

  static const String apiRootUrl = String.fromEnvironment(
    'API_ROOT_URL',
    defaultValue: 'https://attendanceapp-production-2b32.up.railway.app/api/v1',
  );

  static const String mobileApiBaseUrl = '$apiRootUrl/mobile';
  static const String webApiBaseUrl = '$apiRootUrl/web';

  static const String companyDomain = 'b2winfotech.ai';

  static const String googleServerClientId =
      '514104295700-9nnc6c94c26e3j80o9b4ptm9t7n9i6en.apps.googleusercontent.com';
}
