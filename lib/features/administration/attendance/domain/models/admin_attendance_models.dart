import 'package:app/features/administration/shared/domain/models/admin_employee_summary.dart';
import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminAttendanceRecord {
  const AdminAttendanceRecord({
    required this.id,
    required this.user,
    required this.attendanceState,
    required this.date,
    required this.dayType,
    required this.workMode,
    required this.workedMinutes,
    required this.punchInAt,
    required this.punchOutAt,
    required this.todayPlan,
    required this.report,
    this.location,
    this.regularization,
    this.leaveRequest,
  });

  final String id;
  final AdminEmployeeSummary user;
  final String attendanceState;
  final String date;
  final String dayType;
  final String workMode;
  final int workedMinutes;
  final String punchInAt;
  final String punchOutAt;
  final String todayPlan;
  final String report;
  final AdminAttendanceLocation? location;
  final AdminAttendanceLinkedRecord? regularization;
  final AdminAttendanceLinkedRecord? leaveRequest;

  String get statusKey =>
      attendanceState == 'regularized' ? 'present' : attendanceState;

  String get cardKey {
    final fallback = '${user.id}-$date';
    return 'attendance-${id.isEmpty ? fallback : id}';
  }

  bool get hasRegularization => regularization?.hasId ?? false;

  bool get hasLeave => leaveRequest?.hasId ?? false;

  String get regularizationReason => regularization?.reason ?? '';

  String get regularizationOverrideStatus {
    return regularization?.overrideStatus ?? _statusFromAttendanceState;
  }

  bool canOverride({required String today}) {
    if (date.isEmpty || date.compareTo(today) >= 0) return false;
    return dayType == 'workingDay';
  }

  factory AdminAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceRecord(
      id: adminText(json['id']),
      user: AdminEmployeeSummary.fromJson(json['user']),
      attendanceState: adminText(json['attendanceState'], fallback: 'absent'),
      date: adminIsoDay(json['date']),
      dayType: adminText(json['dayType']),
      workMode: adminText(json['workMode']),
      workedMinutes: _toInt(json['workedMinutes']),
      punchInAt: adminText(json['punchInAt']),
      punchOutAt: adminText(json['punchOutAt']),
      todayPlan: adminText(json['todayPlan']),
      report: adminText(json['report']),
      location: AdminAttendanceLocation.fromJsonOrNull(json['location']),
      regularization: AdminAttendanceLinkedRecord.fromJsonOrNull(
        json['regularization'],
      ),
      leaveRequest: AdminAttendanceLinkedRecord.fromJsonOrNull(
        json['leaveRequest'],
      ),
    );
  }

  String get _statusFromAttendanceState {
    return switch (attendanceState) {
      'present' => 'PRESENT',
      'halfDay' => 'HALF_DAY',
      'onLeave' => 'ON_LEAVE',
      _ => 'ABSENT',
    };
  }
}

class AdminAttendanceLocation {
  const AdminAttendanceLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  static AdminAttendanceLocation? fromJsonOrNull(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final latitude = _toNullableDouble(value['latitude']);
    final longitude = _toNullableDouble(value['longitude']);
    if (latitude == null || longitude == null) return null;
    return AdminAttendanceLocation(latitude: latitude, longitude: longitude);
  }
}

class AdminAttendanceLinkedRecord {
  const AdminAttendanceLinkedRecord({
    required this.id,
    this.reason = '',
    this.overrideStatus,
  });

  final String id;
  final String reason;
  final String? overrideStatus;

  bool get hasId => id.isNotEmpty;

  static AdminAttendanceLinkedRecord? fromJsonOrNull(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return AdminAttendanceLinkedRecord(
      id: adminText(value['id']),
      reason: adminText(value['reason']),
      overrideStatus: adminNullableText(value['overrideStatus']),
    );
  }
}

int _toInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _toNullableDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
