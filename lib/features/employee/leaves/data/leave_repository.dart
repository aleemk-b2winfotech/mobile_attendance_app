import 'dart:math' as math;

import 'package:app/data/network/api_client.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

class LeaveRepository {
  LeaveRepository(this._api);

  final ApiClient _api;

  Future<LeaveRequestPage> fetchRequests({
    String? status,
    required int page,
    required int limit,
  }) async {
    final response = await _api.fetchLeaveRequests(
      status: status,
      page: page,
      limit: limit,
    );
    final rows = (response['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LeaveRequest.fromJson)
        .toList(growable: false);
    final meta =
        response['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    final total = meta['total'] as int? ?? rows.length;
    final parsedLimit = meta['limit'] as int? ?? limit;
    final currentPage = meta['page'] as int? ?? page;
    final totalPages = math.max(1, meta['totalPages'] as int? ?? 1);

    return LeaveRequestPage(
      requests: rows,
      currentPage: total == 0 ? 1 : currentPage,
      totalPages: totalPages,
      totalRequests: total,
      pageSize: parsedLimit < 1 ? limit : parsedLimit,
    );
  }

  Future<void> createRequest({
    required String startDate,
    required String endDate,
    required String reason,
  }) {
    return _api.createLeaveRequest(
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  Future<void> cancelRequest(String id) => _api.cancelLeaveRequest(id);

  Future<LeaveThread> fetchRequestThread(String id) async {
    final response = await _api.fetchLeaveRequestThread(id);
    return LeaveThread.fromJson(response);
  }

  Future<void> createThreadMessage({
    required String leaveRequestId,
    String? message,
    String? proposedStartDate,
    String? proposedEndDate,
  }) {
    return _api.createLeaveThreadMessage(
      leaveRequestId: leaveRequestId,
      message: message,
      proposedStartDate: proposedStartDate,
      proposedEndDate: proposedEndDate,
    );
  }

  Future<void> acceptThreadProposal({
    required String leaveRequestId,
    required String messageId,
  }) {
    return _api.acceptLeaveThreadProposal(
      leaveRequestId: leaveRequestId,
      messageId: messageId,
    );
  }

  Future<List<HolidayItem>> fetchHolidays({required String filter}) async {
    final response = await _api.fetchHolidays(filter: filter);
    final data = response['data'] as List<dynamic>? ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(HolidayItem.fromJson)
        .toList(growable: false);
  }

  String toReadableError(Object error) => _api.toReadableError(error);
}

class LeaveRequestPage {
  const LeaveRequestPage({
    required this.requests,
    required this.currentPage,
    required this.totalPages,
    required this.totalRequests,
    required this.pageSize,
  });

  final List<LeaveRequest> requests;
  final int currentPage;
  final int totalPages;
  final int totalRequests;
  final int pageSize;
}
