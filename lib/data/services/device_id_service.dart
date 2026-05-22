import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';

class DeviceIdService {
  DeviceIdService({AndroidId? androidId})
    : _androidId = androidId ?? const AndroidId();

  final AndroidId _androidId;

  Future<String> getCurrentId() async {
    try {
      final raw = await _androidId.getId();
      final normalized = _normalize(raw);
      if (normalized != null) return normalized;
    } on MissingPluginException {
      // Fallback below keeps error surface stable.
    } on PlatformException {
      // Fallback below keeps error surface stable.
    }

    throw PlatformException(
      code: 'device_id_unavailable',
      message: 'Unable to retrieve Android device ID.',
    );
  }

  String? _normalize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed == '02:00:00:00:00:00') return null;
    return trimmed.toLowerCase();
  }
}
