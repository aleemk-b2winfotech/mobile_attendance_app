import 'package:app/data/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  set onTokenRefreshRequired(Future<String?> Function()? callback) {
    _api.onTokenRefreshRequired = callback;
  }

  void setPortal(ApiPortal portal) => _api.setPortal(portal);

  void setAccessToken(String? token) => _api.setAccessToken(token);

  void setDeviceId(String? id) => _api.setDeviceId(id);

  Future<Map<String, dynamic>> loginWithGoogle({
    required String googleToken,
    required ApiPortal portal,
    String? deviceId,
  }) {
    return _api.loginWithGoogle(
      googleToken: googleToken,
      portal: portal,
      deviceId: deviceId,
    );
  }

  Future<Map<String, dynamic>> refreshSession(String refreshToken) {
    return _api.refreshSession(refreshToken);
  }

  Future<void> logout(String refreshToken) => _api.logout(refreshToken);

  Future<void> requestDeviceChangeOnLogin({
    required String googleToken,
    required String deviceId,
    required String reason,
  }) {
    return _api.requestDeviceChangeOnLogin(
      googleToken: googleToken,
      deviceId: deviceId,
      reason: reason,
    );
  }

  Future<Map<String, dynamic>> fetchProfile() => _api.fetchProfile();

  String toReadableError(Object error) => _api.toReadableError(error);
}
