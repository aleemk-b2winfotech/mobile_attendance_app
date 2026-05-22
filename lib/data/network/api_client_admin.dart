part of 'api_client.dart';

extension ApiClientAdmin on ApiClient {
  Future<Map<String, dynamic>> fetchAdminDashboard({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/dashboard/overview',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchAdminUsers({
    String? search,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (role != null && role.isNotEmpty) params['role'] = role;
    if (isActive != null) params['isActive'] = isActive;

    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createAdminUser({
    required String fullName,
    required String email,
    required List<String> roles,
    String? managerUserId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'roles': roles,
        if (managerUserId != null && managerUserId.isNotEmpty)
          'managerUserId': managerUserId,
      },
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> updateAdminUser(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id',
      data: payload,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> deactivateAdminUser(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/deactivate',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> activateAdminUser(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/activate',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchAdminUserLocation(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/$userId/attendance-profile',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> updateAdminUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$userId/attendance-profile',
      data: {
        'officeLatitude': latitude,
        'officeLongitude': longitude,
        'officeRadiusMeters': radiusMeters,
      },
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> fetchAdminAttendanceRecords({
    String? startDate,
    String? endDate,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (status != null && status != 'all') params['status'] = status;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/attendance/records',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchAdminAttendanceOverview({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/attendance/overview',
      queryParameters: params,
    );

    final result = response.data ?? <String, dynamic>{};
    final data = result['data'] as List<dynamic>? ?? const [];
    final meta = result['meta'] as Map<String, dynamic>? ?? const {};
    final aggregate = meta['aggregate'] as Map<String, dynamic>? ?? const {};

    return <String, dynamic>{
      'items': data,
      'aggregate': aggregate,
      'meta': meta,
    };
  }

  Future<Map<String, dynamic>> upsertAdminAttendanceRegularization({
    required String userId,
    required String date,
    required String overrideStatus,
    required String reason,
    String? overridePunchInAt,
    String? overridePunchOutAt,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$userId/attendance-regularizations/$date',
      data: <String, dynamic>{
        'overrideStatus': overrideStatus,
        'reason': reason,
        if (overridePunchInAt != null && overridePunchInAt.isNotEmpty)
          'overridePunchInAt': overridePunchInAt,
        if (overridePunchOutAt != null && overridePunchOutAt.isNotEmpty)
          'overridePunchOutAt': overridePunchOutAt,
      },
    );
    return _readData(response.data);
  }

  Future<void> deleteAdminAttendanceRegularization({
    required String userId,
    required String date,
  }) async {
    await _dio.delete<void>('/users/$userId/attendance-regularizations/$date');
  }

  Future<Map<String, dynamic>> fetchAdminLeaveRequests({
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/leave-requests',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchAdminDeviceChangeRequests({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/device-change-requests',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchAdminUserDeviceChangeLogs({
    required String userId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _dio.get<Map<String, dynamic>>(
      '/users/$userId/device-change-logs',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<void> approveAdminLeaveRequest(String id) async {
    await _dio.patch<void>('/leave-requests/$id/approve', data: const {});
  }

  Future<void> rejectAdminLeaveRequest(String id, String note) async {
    await _dio.patch<void>(
      '/leave-requests/$id/reject',
      data: {'actionNote': note},
    );
  }

  Future<Map<String, dynamic>> fetchAdminLeaveRequestThread(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leave-requests/$id/thread',
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> createAdminLeaveThreadMessage({
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
      '/leave-requests/$leaveRequestId/thread/messages',
      data: data,
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> acceptAdminLeaveThreadProposal({
    required String leaveRequestId,
    required String messageId,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/leave-requests/$leaveRequestId/thread/messages/$messageId/accept',
    );
    return _readData(response.data);
  }

  Future<void> approveAdminDeviceChangeRequest(String id) async {
    await _dio.patch<void>(
      '/device-change-requests/$id/approve',
      data: const {},
    );
  }

  Future<void> rejectAdminDeviceChangeRequest(String id, String note) async {
    await _dio.patch<void>(
      '/device-change-requests/$id/reject',
      data: {'actionNote': note},
    );
  }

  Future<Map<String, dynamic>> fetchAdminHolidays({
    String? startDate,
    String? endDate,
    bool includeDeleted = false,
  }) async {
    final params = <String, dynamic>{'includeDeleted': includeDeleted};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dio.get<Map<String, dynamic>>(
      '/holidays',
      queryParameters: params,
    );
    final payload = response.data ?? <String, dynamic>{};
    final data = payload['data'];
    if (data is List<dynamic>) {
      return <String, dynamic>{'data': data};
    }
    return payload;
  }

  Future<Map<String, dynamic>> createAdminHoliday({
    required String title,
    String? description,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/holidays',
      data: <String, dynamic>{
        'title': title,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return _readData(response.data);
  }

  Future<Map<String, dynamic>> updateAdminHoliday({
    required String id,
    required String title,
    String? description,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/holidays/$id',
      data: <String, dynamic>{
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
      },
    );
    return _readData(response.data);
  }

  Future<void> deleteAdminHoliday({
    required String id,
    required String reason,
  }) async {
    await _dio.delete<void>('/holidays/$id', data: {'reason': reason});
  }

  Future<Map<String, dynamic>> fetchAdminHolidayHistory(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/holidays/$id/history',
    );
    final payload = response.data ?? <String, dynamic>{};
    final data = payload['data'];
    if (data is List<dynamic>) {
      return <String, dynamic>{'data': data};
    }
    return payload;
  }

  Future<Map<String, dynamic>> fetchAdminWorkFromHome({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/attendance/work-from-home',
      queryParameters: params,
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> assignAdminWorkFromHome({
    required String userId,
    required List<Map<String, String>> ranges,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users/$userId/attendance/work-from-home',
      data: {'ranges': ranges},
    );
    return _readData(response.data);
  }

  Future<void> removeAdminWorkFromHome({
    required String userId,
    required String startDate,
    required String endDate,
  }) async {
    await _dio.delete<void>(
      '/users/$userId/attendance/work-from-home',
      data: {
        'ranges': [
          {'startDate': startDate, 'endDate': endDate},
        ],
      },
    );
  }
}
