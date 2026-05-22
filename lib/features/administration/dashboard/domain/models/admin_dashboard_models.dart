import 'package:app/features/administration/holidays/domain/models/admin_holiday_models.dart';
import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminDashboardSnapshot {
  AdminDashboardSnapshot({
    required this.headcount,
    required this.pendingLeaveCount,
    required this.pendingDeviceChangeCount,
    required this.attendance,
    required this.upcomingHolidays,
  });

  final int headcount;
  final int pendingLeaveCount;
  final int pendingDeviceChangeCount;
  final AdminAttendanceSummary attendance;
  final List<AdminHoliday> upcomingHolidays;

  factory AdminDashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSnapshot(
      headcount: json['headcount'] as int? ?? 0,
      pendingLeaveCount: json['pendingLeaveCount'] as int? ?? 0,
      pendingDeviceChangeCount: json['pendingDeviceChangeCount'] as int? ?? 0,
      attendance: AdminAttendanceSummary.fromJson(
        json['attendanceSummary'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      upcomingHolidays: (json['upcomingHolidays'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminHoliday.fromJson)
          .toList(growable: false),
    );
  }
}

class AdminAttendanceSummary {
  AdminAttendanceSummary({
    required this.presentDays,
    required this.absentDays,
    required this.attendancePercentage,
  });

  final int presentDays;
  final int absentDays;
  final double attendancePercentage;

  factory AdminAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceSummary(
      presentDays: _toInt(json['presentDays']),
      absentDays: _toInt(json['absentDays']),
      attendancePercentage: adminToDouble(json['attendancePercentage']),
    );
  }
}

int _toInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
