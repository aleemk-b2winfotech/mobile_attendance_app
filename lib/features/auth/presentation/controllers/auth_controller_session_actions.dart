part of 'auth_controller.dart';

extension AuthControllerSessionActions on AuthController {
  Future<void> _bootstrap() async {
    isLoading.value = true;

    try {
      _accessToken = await _storage.read(key: AuthStorageKeys.accessToken);
      _refreshToken = await _storage.read(key: AuthStorageKeys.refreshToken);
      _sessionPortal = _portalFromStorage(
        await _storage.read(key: AuthStorageKeys.sessionPortal),
      );
      _repository.setPortal(_sessionPortal);

      final storedDevice = await _storage.read(key: AuthStorageKeys.deviceId);
      _deviceId = await _deviceIdService.getCurrentId();

      if (storedDevice != _deviceId) {
        await _storage.write(key: AuthStorageKeys.deviceId, value: _deviceId);
      }

      _repository.setDeviceId(_deviceId);

      if (_accessToken != null && _refreshToken != null) {
        _repository.setAccessToken(_accessToken);
        final cachedUser = await _readCachedUserProfile();
        if (cachedUser != null) {
          await _applyUserProfile(cachedUser);
        }

        try {
          final profileJson = await _repository.fetchProfile();
          await _applyUserProfile(UserProfile.fromJson(profileJson));
        } catch (error) {
          if (_isConnectivityIssue(error)) {
            return;
          }
          await _refreshTokensWithLock();
        }
      }
    } catch (error) {
      if (error is Exception) {
        errorText.value = error.toString().replaceFirst('Exception: ', '');
      }
      await _clearSession();
    } finally {
      isInitialized.value = true;
      isLoading.value = false;
    }
  }

  Future<String?> _handleAccessTokenExpired() {
    return _refreshTokensWithLock();
  }

  Future<String?> _refreshTokensWithLock() async {
    if (_refreshToken == null) return null;

    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final call = _performRefresh();
    _refreshInFlight = call;

    try {
      return await call;
    } finally {
      if (identical(_refreshInFlight, call)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<String?> _performRefresh() async {
    try {
      final payload = await _repository.refreshSession(_refreshToken!);

      _accessToken = payload['accessToken'] as String;
      _refreshToken = payload['refreshToken'] as String;

      _repository.setAccessToken(_accessToken);

      await _storage.write(
        key: AuthStorageKeys.accessToken,
        value: _accessToken,
      );
      await _storage.write(
        key: AuthStorageKeys.refreshToken,
        value: _refreshToken,
      );

      if (user.value == null) {
        final profileJson = await _repository.fetchProfile();
        await _applyUserProfile(UserProfile.fromJson(profileJson));
        return _accessToken;
      }

      _registerFeatureControllers();
      return _accessToken;
    } catch (error) {
      if (_isConnectivityIssue(error)) {
        return null;
      }
      await _clearSession();
      return null;
    }
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    user.value = null;
    _sessionPortal = ApiPortal.employee;

    _repository.setAccessToken(null);
    _repository.setPortal(ApiPortal.employee);

    await _storage.delete(key: AuthStorageKeys.accessToken);
    await _storage.delete(key: AuthStorageKeys.refreshToken);
    await _storage.delete(key: AuthStorageKeys.sessionPortal);
    await _storage.delete(key: AuthStorageKeys.userProfile);

    FeatureControllerRegistry.clearSessionControllers();
  }

  Future<void> _applyUserProfile(UserProfile profile) async {
    _registerFeatureControllers();
    user.value = profile;
    await _storage.write(
      key: AuthStorageKeys.userProfile,
      value: jsonEncode(profile.toJson()),
    );
  }

  Future<UserProfile?> _readCachedUserProfile() async {
    final raw = await _storage.read(key: AuthStorageKeys.userProfile);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await _storage.delete(key: AuthStorageKeys.userProfile);
    }

    return null;
  }

  void _registerFeatureControllers() {
    FeatureControllerRegistry.registerForPortal(_sessionPortal);
  }

  ApiPortal _portalFromStorage(String? value) {
    return value == 'admin' ? ApiPortal.admin : ApiPortal.employee;
  }

  String _portalToStorage(ApiPortal portal) {
    return switch (portal) {
      ApiPortal.employee => 'employee',
      ApiPortal.admin => 'admin',
    };
  }
}
