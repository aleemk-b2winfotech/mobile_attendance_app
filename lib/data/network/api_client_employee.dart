part of 'api_client.dart';

extension ApiClientEmployee on ApiClient {
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/profile');
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/dashboard');
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchHolidays({
    String filter = 'all',
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{'filter': filter};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dio.get<Map<String, dynamic>>(
      '/me/holidays',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchAttendanceOverview({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dio.get<Map<String, dynamic>>(
      '/me/attendance/overview',
      queryParameters: params,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> punchIn({
    double? latitude,
    double? longitude,
    String? todayPlan,
  }) async {
    final data = <String, dynamic>{};
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (todayPlan != null && todayPlan.trim().isNotEmpty) {
      data['todayPlan'] = todayPlan.trim();
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/me/attendance/punch-in',
      data: data.isEmpty ? null : data,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> punchOut({
    double? latitude,
    double? longitude,
    String? report,
  }) async {
    final data = <String, dynamic>{};
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (report != null && report.trim().isNotEmpty) {
      data['report'] = report.trim();
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/me/attendance/punch-out',
      data: data.isEmpty ? null : data,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchLeaveRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;

    final response = await _dio.get<Map<String, dynamic>>(
      '/me/leave-requests',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createLeaveRequest({
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/me/leave-requests',
      data: {'startDate': startDate, 'endDate': endDate, 'reason': reason},
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> cancelLeaveRequest(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/me/leave-requests/$id/cancel',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchLeaveRequestThread(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/leave-requests/$id/thread',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> createLeaveThreadMessage({
    required String leaveRequestId,
    String? message,
    String? proposedStartDate,
    String? proposedEndDate,
  }) async {
    final data = <String, dynamic>{};
    final trimmedMessage = message?.trim();
    if (trimmedMessage != null && trimmedMessage.isNotEmpty) {
      data['message'] = trimmedMessage;
    }
    if (proposedStartDate != null) {
      data['proposedStartDate'] = proposedStartDate;
    }
    if (proposedEndDate != null) {
      data['proposedEndDate'] = proposedEndDate;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/me/leave-requests/$leaveRequestId/thread/messages',
      data: data,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> acceptLeaveThreadProposal({
    required String leaveRequestId,
    required String messageId,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/me/leave-requests/$leaveRequestId/thread/messages/$messageId/accept',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchDeviceChangeRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;

    final response = await _dio.get<Map<String, dynamic>>(
      '/me/device-change-requests',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createDeviceChangeRequest({
    required String requestedDeviceId,
    required String reason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/me/device-change-requests',
      data: {'requestedDeviceId': requestedDeviceId, 'reason': reason},
    );
    return _readData(response.data);
  }
}
