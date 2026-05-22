import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';

part 'api_client_admin.dart';
part 'api_client_auth.dart';
part 'api_client_employee.dart';
part 'api_client_errors.dart';

enum ApiPortal { employee, admin }

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.mobileApiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final deviceId = _deviceId;
          if (deviceId != null && deviceId.isNotEmpty) {
            options.headers['x-device-id'] = deviceId;
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          if (_shouldRetryConnectionError(error)) {
            final retryCount =
                request.extra['connectionRetryCount'] as int? ?? 0;
            request.extra['connectionRetryCount'] = retryCount + 1;
            await Future<void>.delayed(
              Duration(milliseconds: 350 * (retryCount + 1)),
            );

            try {
              final retryResponse = await _dio.fetch(request);
              handler.resolve(retryResponse);
            } catch (retryError) {
              handler.next(retryError is DioException ? retryError : error);
            }
            return;
          }

          final canRetry =
              error.response?.statusCode == 401 &&
              onTokenRefreshRequired != null &&
              request.extra['skipAuthRefresh'] != true &&
              request.extra['retryAfterRefresh'] != true &&
              !request.path.endsWith('/auth/refresh');

          if (!canRetry) {
            handler.next(error);
            return;
          }

          final refreshedToken = await onTokenRefreshRequired?.call();
          if (refreshedToken == null) {
            handler.next(error);
            return;
          }

          _accessToken = refreshedToken;
          request.headers['Authorization'] = 'Bearer $refreshedToken';
          request.extra['retryAfterRefresh'] = true;

          final retryResponse = await _dio.fetch(request);
          handler.resolve(retryResponse);
        },
      ),
    );
  }

  late final Dio _dio;
  String? _accessToken;
  String? _deviceId;
  ApiPortal _portal = ApiPortal.employee;

  Future<String?> Function()? onTokenRefreshRequired;

  ApiPortal get portal => _portal;

  void setPortal(ApiPortal portal) {
    _portal = portal;
    _dio.options.baseUrl = switch (portal) {
      ApiPortal.employee => AppConfig.mobileApiBaseUrl,
      ApiPortal.admin => AppConfig.webApiBaseUrl,
    };
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setDeviceId(String? id) {
    _deviceId = id;
  }
}

Map<String, dynamic> _readData(Map<String, dynamic>? payload) {
  if (payload == null) return <String, dynamic>{};
  final data = payload['data'];
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{};
}

bool _shouldRetryConnectionError(DioException error) {
  final request = error.requestOptions;
  final retryCount = request.extra['connectionRetryCount'] as int? ?? 0;
  if (retryCount >= 2) return false;

  final isTransient = <DioExceptionType>{
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.connectionError,
  }.contains(error.type);
  if (!isTransient) return false;

  return request.method.toUpperCase() == 'GET' ||
      request.extra['retryOnConnectionFailure'] == true;
}
