import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/analytics/domain/models/admin_analytics_models.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

class AdminAnalyticsRepository implements AdminRepositoryBase {
  AdminAnalyticsRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchAttendanceOverview({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminAttendanceOverview(
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<AdminAnalyticsResult> fetchAttendanceOverviewResult({
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchAttendanceOverview(
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
    return AdminAnalyticsResult(
      rows: (response['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminAnalyticsRow.fromJson)
          .toList(growable: false),
      aggregate: AdminAnalyticsAggregate.fromJson(response['aggregate']),
      meta: AdminPaginationMeta.fromJson(response['meta']),
    );
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
