import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/dashboard/domain/models/admin_dashboard_models.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';

class AdminDashboardRepository implements AdminRepositoryBase {
  AdminDashboardRepository(this._api);

  final ApiClient _api;

  Future<AdminDashboardSnapshot> fetchSnapshot({
    required String startDate,
    required String endDate,
  }) async {
    final payload = await _api.fetchAdminDashboard(
      startDate: startDate,
      endDate: endDate,
    );
    return AdminDashboardSnapshot.fromJson(payload);
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);
}
