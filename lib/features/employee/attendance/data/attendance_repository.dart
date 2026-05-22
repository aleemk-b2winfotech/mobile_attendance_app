import 'package:app/data/network/api_client.dart';
import 'package:app/features/employee/attendance/domain/models/attendance_models.dart';

class AttendanceRepository {
  AttendanceRepository(this._api);

  final ApiClient _api;

  Future<AttendanceOverview> fetchOverview({
    required String startDate,
    required String endDate,
  }) async {
    final payload = await _api.fetchAttendanceOverview(
      startDate: startDate,
      endDate: endDate,
    );
    return AttendanceOverview.fromJson(payload);
  }

  Future<void> punchIn({
    double? latitude,
    double? longitude,
    String? todayPlan,
  }) {
    return _api.punchIn(
      latitude: latitude,
      longitude: longitude,
      todayPlan: todayPlan,
    );
  }

  Future<void> punchOut({double? latitude, double? longitude, String? report}) {
    return _api.punchOut(
      latitude: latitude,
      longitude: longitude,
      report: report,
    );
  }

  String toReadableError(Object error) => _api.toReadableError(error);
}
