import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

class AdminUser {
  AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
    required this.isActive,
    this.managerUserId,
    this.managerName,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;
  final bool isActive;
  final String? managerUserId;
  final String? managerName;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final manager = json['manager'];
    return AdminUser(
      id: adminText(json['id']),
      fullName: adminText(json['fullName'], fallback: 'Unnamed user'),
      email: adminText(json['email']),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      isActive: json['isActive'] as bool? ?? true,
      managerUserId: adminNullableText(json['managerUserId']),
      managerName: manager is Map<String, dynamic>
          ? adminNullableText(manager['fullName'])
          : null,
    );
  }
}

class AdminUserDraft {
  const AdminUserDraft({
    required this.fullName,
    required this.email,
    required this.role,
    this.managerUserId,
  });

  final String fullName;
  final String email;
  final String role;
  final String? managerUserId;

  String? validate() {
    if (fullName.trim().isEmpty) return 'Full name is required.';
    if (email.trim().isEmpty) return 'Email is required.';
    if (role.trim().isEmpty) return 'Role is required.';
    return null;
  }
}

class AdminUserLocationDraft {
  const AdminUserLocationDraft({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;

  static AdminUserLocationDraft? tryParse({
    required String latitude,
    required String longitude,
    required String radiusMeters,
  }) {
    final parsedLatitude = double.tryParse(latitude.trim());
    final parsedLongitude = double.tryParse(longitude.trim());
    final parsedRadius = int.tryParse(radiusMeters.trim());

    if (parsedLatitude == null ||
        parsedLongitude == null ||
        parsedRadius == null) {
      return null;
    }

    return AdminUserLocationDraft(
      latitude: parsedLatitude,
      longitude: parsedLongitude,
      radiusMeters: parsedRadius,
    );
  }
}

class AdminDeviceChangeLog {
  const AdminDeviceChangeLog({
    required this.id,
    required this.status,
    required this.requestedDeviceId,
    required this.createdAt,
    this.currentDeviceIdSnapshot,
    this.reason = '',
    this.actionNote = '',
    this.actionAt,
    this.actionByName = '',
  });

  final String id;
  final String status;
  final String requestedDeviceId;
  final String createdAt;
  final String? currentDeviceIdSnapshot;
  final String reason;
  final String actionNote;
  final String? actionAt;
  final String actionByName;

  factory AdminDeviceChangeLog.fromJson(Map<String, dynamic> json) {
    final actionBy = adminUserMap(json['actionBy']);
    return AdminDeviceChangeLog(
      id: adminText(json['id']),
      status: adminText(json['status'], fallback: 'PENDING'),
      requestedDeviceId: adminText(json['requestedDeviceId']),
      createdAt: adminText(json['createdAt']),
      currentDeviceIdSnapshot: adminNullableText(
        json['currentDeviceIdSnapshot'],
      ),
      reason: adminText(json['reason']),
      actionNote: adminText(json['actionNote']),
      actionAt: adminNullableText(json['actionAt']),
      actionByName: actionBy['fullName'] ?? '',
    );
  }
}

class AdminDeviceLogResult {
  const AdminDeviceLogResult({required this.rows, required this.meta});

  final List<AdminDeviceChangeLog> rows;
  final AdminPaginationMeta meta;
}
