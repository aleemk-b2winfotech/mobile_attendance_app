import 'package:app/features/administration/shared/domain/models/admin_employee_summary.dart';
import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminWfhRecord implements Comparable<AdminWfhRecord> {
  const AdminWfhRecord({required this.user, required this.attendanceDate});

  final AdminEmployeeSummary user;
  final String attendanceDate;

  factory AdminWfhRecord.fromJson(Map<String, dynamic> json) {
    return AdminWfhRecord(
      user: AdminEmployeeSummary.fromJson(json['user']),
      attendanceDate: adminIsoDay(json['attendanceDate']),
    );
  }

  @override
  int compareTo(AdminWfhRecord other) {
    if (attendanceDate.isEmpty && other.attendanceDate.isEmpty) {
      return _compareEmployee(other);
    }
    if (attendanceDate.isEmpty) return 1;
    if (other.attendanceDate.isEmpty) return -1;

    final dateOrder = other.attendanceDate.compareTo(attendanceDate);
    if (dateOrder != 0) return dateOrder;
    return _compareEmployee(other);
  }

  int _compareEmployee(AdminWfhRecord other) {
    return user.fullName.compareTo(other.user.fullName);
  }
}
