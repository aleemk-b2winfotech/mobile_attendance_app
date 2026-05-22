import 'package:app/features/administration/shared/domain/models/admin_employee_summary.dart';
import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

class AdminAnalyticsResult {
  const AdminAnalyticsResult({
    required this.rows,
    required this.aggregate,
    required this.meta,
  });

  final List<AdminAnalyticsRow> rows;
  final AdminAnalyticsAggregate aggregate;
  final AdminPaginationMeta meta;
}

class AdminAnalyticsAggregate {
  const AdminAnalyticsAggregate({
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.attendancePercentage,
  });

  const AdminAnalyticsAggregate.empty()
    : presentDays = 0,
      halfDays = 0,
      absentDays = 0,
      attendancePercentage = 0;

  final int presentDays;
  final int halfDays;
  final int absentDays;
  final double attendancePercentage;

  factory AdminAnalyticsAggregate.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const AdminAnalyticsAggregate.empty();
    }
    return AdminAnalyticsAggregate(
      presentDays: _toInt(value['presentDays']),
      halfDays: _toInt(value['halfDays']),
      absentDays: _toInt(value['absentDays']),
      attendancePercentage: adminToDouble(value['attendancePercentage']),
    );
  }
}

class AdminAnalyticsRow {
  const AdminAnalyticsRow({required this.user, required this.summary});

  final AdminEmployeeSummary user;
  final AdminAnalyticsSummary summary;

  factory AdminAnalyticsRow.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsRow(
      user: AdminEmployeeSummary.fromJson(json['user']),
      summary: AdminAnalyticsSummary.fromJson(json['summary']),
    );
  }
}

class AdminAnalyticsSummary {
  const AdminAnalyticsSummary({
    required this.presentDays,
    required this.halfDays,
    required this.absentDays,
    required this.totalWorkedMinutes,
    required this.attendancePercentage,
  });

  final int presentDays;
  final int halfDays;
  final int absentDays;
  final int totalWorkedMinutes;
  final double attendancePercentage;

  factory AdminAnalyticsSummary.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const AdminAnalyticsSummary(
        presentDays: 0,
        halfDays: 0,
        absentDays: 0,
        totalWorkedMinutes: 0,
        attendancePercentage: 0,
      );
    }
    return AdminAnalyticsSummary(
      presentDays: _toInt(value['presentDays']),
      halfDays: _toInt(value['halfDays']),
      absentDays: _toInt(value['absentDays']),
      totalWorkedMinutes: _toInt(value['totalWorkedMinutes']),
      attendancePercentage: adminToDouble(value['attendancePercentage']),
    );
  }
}

int _toInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
