import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/holidays/domain/models/admin_holiday_models.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/data/admin_response_helpers.dart';

class AdminHolidayRepository implements AdminRepositoryBase {
  AdminHolidayRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchHolidays({
    String? startDate,
    String? endDate,
    bool includeDeleted = false,
  }) {
    return _api.fetchAdminHolidays(
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );
  }

  Future<List<AdminHoliday>> fetchHolidayRows({
    String? startDate,
    String? endDate,
    bool includeDeleted = false,
  }) async {
    final response = await fetchHolidays(
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );
    return adminRowsFromResponse(
      response,
    ).map(AdminHoliday.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> createHoliday({
    required String title,
    String? description,
    required String startDate,
    required String endDate,
  }) {
    return _api.createAdminHoliday(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> updateHoliday({
    required String id,
    required String title,
    String? description,
    required String startDate,
    required String endDate,
    required String reason,
  }) {
    return _api.updateAdminHoliday(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  Future<void> deleteHoliday({required String id, required String reason}) {
    return _api.deleteAdminHoliday(id: id, reason: reason);
  }

  Future<Map<String, dynamic>> fetchHolidayHistory(String id) {
    return _api.fetchAdminHolidayHistory(id);
  }

  Future<List<AdminHolidayHistoryEntry>> fetchHolidayHistoryRows(
    String id,
  ) async {
    final response = await fetchHolidayHistory(id);
    return adminRowsFromResponse(
      response,
    ).map(AdminHolidayHistoryEntry.fromJson).toList(growable: false);
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
