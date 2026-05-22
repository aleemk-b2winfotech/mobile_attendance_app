part of 'api_client.dart';

extension ApiClientAuth on ApiClient {
  Future<Map<String, dynamic>> loginWithGoogle({
    required String googleToken,
    required ApiPortal portal,
    String? deviceId,
  }) async {
    final previousPortal = _portal;
    setPortal(ApiPortal.employee);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google/login',
        data: <String, dynamic>{
          'googleToken': googleToken,
          'portal': switch (portal) {
            ApiPortal.employee => 'employee',
            ApiPortal.admin => 'admin',
          },
          if (portal == ApiPortal.employee && deviceId != null)
            'deviceId': deviceId,
        },
        options: Options(
          extra: const {
            'skipAuthRefresh': true,
            'retryOnConnectionFailure': true,
          },
        ),
      );
      final data = _readData(response.data);
      setPortal(portal);
      return data;
    } catch (_) {
      setPortal(previousPortal);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    final activePortal = _portal;
    setPortal(ApiPortal.employee);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: const {
            'skipAuthRefresh': true,
            'retryOnConnectionFailure': true,
          },
        ),
      );
      return _readData(response.data);
    } finally {
      setPortal(activePortal);
    }
  }

  Future<void> logout(String refreshToken) async {
    final activePortal = _portal;
    setPortal(ApiPortal.employee);

    try {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: const {
            'skipAuthRefresh': true,
            'retryOnConnectionFailure': true,
          },
        ),
      );
    } finally {
      setPortal(activePortal);
    }
  }

  Future<void> requestDeviceChangeOnLogin({
    required String googleToken,
    required String deviceId,
    required String reason,
  }) async {
    await _dio.post<void>(
      '/auth/device-change-request',
      data: {
        'googleToken': googleToken,
        'deviceId': deviceId,
        'reason': reason,
      },
      options: Options(extra: const {'skipAuthRefresh': true}),
    );
  }
}
