import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/attendance/domain/models/admin_attendance_models.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/data/admin_response_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

class AdminAttendanceRepository implements AdminRepositoryBase {
  AdminAttendanceRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchAttendanceRecords({
    String? startDate,
    String? endDate,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminAttendanceRecords(
      startDate: startDate,
      endDate: endDate,
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<AdminPagedResult<AdminAttendanceRecord>> fetchAttendanceRecordPage({
    String? startDate,
    String? endDate,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchAttendanceRecords(
      startDate: startDate,
      endDate: endDate,
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
    return AdminPagedResult(
      rows: adminRowsFromResponse(
        response,
      ).map(AdminAttendanceRecord.fromJson).toList(growable: false),
      meta: AdminPaginationMeta.fromJson(adminMetaFromResponse(response)),
    );
  }

  Future<void> upsertAttendanceRegularization({
    required String userId,
    required String date,
    required String overrideStatus,
    required String reason,
    String? overridePunchInAt,
    String? overridePunchOutAt,
  }) {
    return _api.upsertAdminAttendanceRegularization(
      userId: userId,
      date: date,
      overrideStatus: overrideStatus,
      reason: reason,
      overridePunchInAt: overridePunchInAt,
      overridePunchOutAt: overridePunchOutAt,
    );
  }

  Future<void> deleteAttendanceRegularization({
    required String userId,
    required String date,
  }) {
    return _api.deleteAdminAttendanceRegularization(userId: userId, date: date);
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
