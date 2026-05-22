import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/approvals/domain/models/admin_approval_models.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/data/admin_response_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

class AdminApprovalRepository implements AdminRepositoryBase {
  AdminApprovalRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchLeaveRequests({
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminLeaveRequests(
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<List<AdminApprovalItem>> fetchLeaveApprovalItems({
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchLeaveRequests(
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
    return adminRowsFromResponse(
      response,
    ).map(AdminApprovalItem.leave).toList(growable: false);
  }

  Future<AdminPagedResult<AdminApprovalItem>> fetchLeaveApprovalPage({
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchLeaveRequests(
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
    return AdminPagedResult(
      rows: adminRowsFromResponse(
        response,
      ).map(AdminApprovalItem.leave).toList(growable: false),
      meta: AdminPaginationMeta.fromJson(adminMetaFromResponse(response)),
    );
  }

  Future<Map<String, dynamic>> fetchDeviceChangeRequests({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminDeviceChangeRequests(
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<List<AdminApprovalItem>> fetchDeviceChangeApprovalItems({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchDeviceChangeRequests(
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
    return adminRowsFromResponse(
      response,
    ).map(AdminApprovalItem.deviceChange).toList(growable: false);
  }

  Future<AdminPagedResult<AdminApprovalItem>> fetchDeviceChangeApprovalPage({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchDeviceChangeRequests(
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
    return AdminPagedResult(
      rows: adminRowsFromResponse(
        response,
      ).map(AdminApprovalItem.deviceChange).toList(growable: false),
      meta: AdminPaginationMeta.fromJson(adminMetaFromResponse(response)),
    );
  }

  Future<void> approveLeaveRequest(String id) {
    return _api.approveAdminLeaveRequest(id);
  }

  Future<void> rejectLeaveRequest(String id, String note) {
    return _api.rejectAdminLeaveRequest(id, note);
  }

  Future<Map<String, dynamic>> fetchLeaveRequestThread(String id) {
    return _api.fetchAdminLeaveRequestThread(id);
  }

  Future<void> createLeaveThreadMessage({
    required String leaveRequestId,
    String? message,
    String? proposedStartDate,
    String? proposedEndDate,
  }) {
    return _api.createAdminLeaveThreadMessage(
      leaveRequestId: leaveRequestId,
      message: message,
      proposedStartDate: proposedStartDate,
      proposedEndDate: proposedEndDate,
    );
  }

  Future<void> acceptLeaveThreadProposal({
    required String leaveRequestId,
    required String messageId,
  }) {
    return _api.acceptAdminLeaveThreadProposal(
      leaveRequestId: leaveRequestId,
      messageId: messageId,
    );
  }

  Future<void> approveDeviceChangeRequest(String id) {
    return _api.approveAdminDeviceChangeRequest(id);
  }

  Future<void> rejectDeviceChangeRequest(String id, String note) {
    return _api.rejectAdminDeviceChangeRequest(id, note);
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
