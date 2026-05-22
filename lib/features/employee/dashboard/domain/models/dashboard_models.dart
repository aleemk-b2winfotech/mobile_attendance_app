import 'package:app/features/employee/shared/domain/models/employee_user_summary.dart';

class DashboardSnapshot {
  DashboardSnapshot({
    required this.today,
    required this.month,
    required this.pendingLeaves,
    required this.upcomingHolidays,
    required this.upcomingWfhDays,
    this.user,
  });

  final DashboardUser? user;
  final TodayAttendance today;
  final MonthAttendance month;
  final List<PendingLeaveItem> pendingLeaves;
  final List<UpcomingHolidayItem> upcomingHolidays;
  final List<String> upcomingWfhDays;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final rawWfh = (json['upcomingWFHDays'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map((value) => value.length > 10 ? value.substring(0, 10) : value)
        .toList(growable: false);

    return DashboardSnapshot(
      user: json['user'] is Map<String, dynamic>
          ? DashboardUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      today: TodayAttendance.fromJson(
        json['todayStatus'] as Map<String, dynamic>,
      ),
      month: MonthAttendance.fromJson(
        json['monthSummary'] as Map<String, dynamic>,
      ),
      pendingLeaves: (json['pendingLeaves'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PendingLeaveItem.fromJson)
          .toList(growable: false),
      upcomingHolidays: (json['upcomingHolidays'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(UpcomingHolidayItem.fromJson)
          .toList(growable: false),
      upcomingWfhDays: rawWfh,
    );
  }
}

class DashboardUser {
  DashboardUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
    this.manager,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;
  final EmployeeUserSummary? manager;

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      manager: json['manager'] is Map<String, dynamic>
          ? EmployeeUserSummary.fromJson(json['manager'])
          : null,
    );
  }
}

class TodayAttendance {
  TodayAttendance({
    required this.date,
    required this.status,
    this.workMode,
    this.todayPlan,
    this.report,
    this.punchInAt,
    this.punchOutAt,
    this.workedMinutes,
    this.holiday,
  });

  final String date;
  final String status;
  final String? workMode;
  final String? todayPlan;
  final String? report;
  final String? punchInAt;
  final String? punchOutAt;
  final int? workedMinutes;
  final String? holiday;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      date: json['date'] as String,
      status: json['status'] as String,
      workMode: json['workMode'] as String?,
      todayPlan: json['todayPlan'] as String?,
      report: json['report'] as String?,
      punchInAt: json['punchInAt'] as String?,
      punchOutAt: json['punchOutAt'] as String?,
      workedMinutes: json['workedMinutes'] as int?,
      holiday: json['holiday'] as String?,
    );
  }
}

class MonthAttendance {
  MonthAttendance({
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.leaveDays,
    required this.holidayDays,
    required this.weeklyOffDays,
    required this.attendancePercentage,
  });

  final int presentDays;
  final int halfDays;
  final int absentDays;
  final int leaveDays;
  final int holidayDays;
  final int weeklyOffDays;
  final double attendancePercentage;

  factory MonthAttendance.fromJson(Map<String, dynamic> json) {
    return MonthAttendance(
      presentDays: json['presentDays'] as int? ?? 0,
      halfDays: json['halfDays'] as int? ?? 0,
      absentDays: json['absentDays'] as int? ?? 0,
      leaveDays: json['leaveDays'] as int? ?? 0,
      holidayDays: json['holidayDays'] as int? ?? 0,
      weeklyOffDays: json['weeklyOffDays'] as int? ?? 0,
      attendancePercentage:
          (json['attendancePercentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PendingLeaveItem {
  PendingLeaveItem({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.workingDayCount,
    required this.reason,
    required this.status,
    this.approvedStartDate,
    this.approvedEndDate,
    this.approvedWorkingDayCount,
  });

  final String id;
  final String startDate;
  final String endDate;
  final int workingDayCount;
  final String reason;
  final String status;
  final String? approvedStartDate;
  final String? approvedEndDate;
  final int? approvedWorkingDayCount;

  String get effectiveStartDate => approvedStartDate ?? startDate;

  String get effectiveEndDate => approvedEndDate ?? endDate;

  int get effectiveWorkingDayCount =>
      approvedWorkingDayCount ?? workingDayCount;

  factory PendingLeaveItem.fromJson(Map<String, dynamic> json) {
    return PendingLeaveItem(
      id: json['id'] as String,
      startDate: _normalizeDate(json['startDate'] as String? ?? ''),
      endDate: _normalizeDate(json['endDate'] as String? ?? ''),
      workingDayCount: json['workingDayCount'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      approvedStartDate: _normalizeNullableDate(json['approvedStartDate']),
      approvedEndDate: _normalizeNullableDate(json['approvedEndDate']),
      approvedWorkingDayCount: json['approvedWorkingDayCount'] as int?,
    );
  }
}

class UpcomingHolidayItem {
  UpcomingHolidayItem({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String startDate;
  final String endDate;

  factory UpcomingHolidayItem.fromJson(Map<String, dynamic> json) {
    return UpcomingHolidayItem(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: _normalizeDate(json['startDate'] as String? ?? ''),
      endDate: _normalizeDate(json['endDate'] as String? ?? ''),
    );
  }
}

String _normalizeDate(String date) {
  if (date.length <= 10) return date;
  return date.substring(0, 10);
}

String? _normalizeNullableDate(Object? value) {
  final date = value?.toString() ?? '';
  if (date.isEmpty) return null;
  return _normalizeDate(date);
}
