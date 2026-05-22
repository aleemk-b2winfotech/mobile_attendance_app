import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/data/admin_response_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';
import 'package:app/features/administration/work_from_home/domain/models/admin_wfh_models.dart';

class AdminWorkFromHomeRepository implements AdminRepositoryBase {
  AdminWorkFromHomeRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchWorkFromHome({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminWorkFromHome(
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<AdminPagedResult<AdminWfhRecord>> fetchWorkFromHomePage({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchWorkFromHome(
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
    return AdminPagedResult(
      rows: adminRowsFromResponse(
        response,
      ).map(AdminWfhRecord.fromJson).toList(growable: false),
      meta: AdminPaginationMeta.fromJson(adminMetaFromResponse(response)),
    );
  }

  Future<Map<String, dynamic>> assignWorkFromHome({
    required String userId,
    required List<Map<String, String>> ranges,
  }) {
    return _api.assignAdminWorkFromHome(userId: userId, ranges: ranges);
  }

  Future<void> removeWorkFromHome({
    required String userId,
    required String startDate,
    required String endDate,
  }) {
    return _api.removeAdminWorkFromHome(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
