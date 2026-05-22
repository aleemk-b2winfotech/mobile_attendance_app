import 'package:app/data/network/api_client.dart';
import 'package:app/features/employee/dashboard/domain/models/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._api);

  final ApiClient _api;

  Future<DashboardSnapshot> fetchSnapshot() async {
    final payload = await _api.fetchDashboard();
    return DashboardSnapshot.fromJson(payload);
  }

  String toReadableError(Object error) => _api.toReadableError(error);
}
