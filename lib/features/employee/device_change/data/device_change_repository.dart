import 'package:app/data/network/api_client.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

class DeviceChangeRepository {
  DeviceChangeRepository(this._api);

  final ApiClient _api;

  Future<List<DeviceChangeRequest>> fetchRequests() async {
    final response = await _api.fetchDeviceChangeRequests();
    return (response['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(DeviceChangeRequest.fromJson)
        .toList(growable: false);
  }

  Future<void> submitRequest({
    required String requestedDeviceId,
    required String reason,
  }) {
    return _api.createDeviceChangeRequest(
      requestedDeviceId: requestedDeviceId,
      reason: reason,
    );
  }

  String toReadableError(Object error) => _api.toReadableError(error);
}
