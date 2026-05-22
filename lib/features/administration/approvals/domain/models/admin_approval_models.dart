import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminApprovalItem {
  AdminApprovalItem({
    required this.id,
    required this.kind,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.title,
    required this.detail,
    required this.status,
    required this.createdAt,
    this.reason = '',
    this.startDate = '',
    this.endDate = '',
    this.approvedStartDate,
    this.approvedEndDate,
    this.workingDayCount = 0,
    this.approvedWorkingDayCount,
  });

  final String id;
  final AdminApprovalKind kind;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String title;
  final String detail;
  final String status;
  final String createdAt;
  final String reason;
  final String startDate;
  final String endDate;
  final String? approvedStartDate;
  final String? approvedEndDate;
  final int workingDayCount;
  final int? approvedWorkingDayCount;

  String get effectiveStartDate => approvedStartDate ?? startDate;

  String get effectiveEndDate => approvedEndDate ?? endDate;

  int get effectiveWorkingDayCount =>
      approvedWorkingDayCount ?? workingDayCount;

  factory AdminApprovalItem.leave(Map<String, dynamic> json) {
    final user = adminUserMap(json['user']);
    final start = adminIsoDay(json['approvedStartDate'] ?? json['startDate']);
    final end = adminIsoDay(json['approvedEndDate'] ?? json['endDate']);
    final dayCount =
        json['approvedWorkingDayCount'] as int? ??
        json['workingDayCount'] as int? ??
        0;
    final reason = adminText(json['reason']);
    final detail = dayCount > 0
        ? '$reason\n$dayCount working ${dayCount == 1 ? 'day' : 'days'}'
        : reason;
    return AdminApprovalItem(
      id: adminText(json['id']),
      kind: AdminApprovalKind.leave,
      employeeId: user['id'] ?? '',
      employeeName: user['fullName'] ?? 'Employee',
      employeeEmail: user['email'] ?? '',
      title: start == end ? start : '$start to $end',
      detail: detail.trim(),
      status: adminText(json['status']),
      createdAt: adminIsoDay(json['createdAt']),
      reason: reason,
      startDate: adminIsoDay(json['startDate']),
      endDate: adminIsoDay(json['endDate']),
      approvedStartDate: adminNullableText(
        adminIsoDay(json['approvedStartDate']),
      ),
      approvedEndDate: adminNullableText(adminIsoDay(json['approvedEndDate'])),
      workingDayCount: json['workingDayCount'] as int? ?? 0,
      approvedWorkingDayCount: json['approvedWorkingDayCount'] as int?,
    );
  }

  factory AdminApprovalItem.deviceChange(Map<String, dynamic> json) {
    final user = adminUserMap(json['user']);
    return AdminApprovalItem(
      id: adminText(json['id']),
      kind: AdminApprovalKind.deviceChange,
      employeeId: user['id'] ?? '',
      employeeName: user['fullName'] ?? 'Employee',
      employeeEmail: user['email'] ?? '',
      title: 'Device change',
      detail: adminText(json['reason']),
      status: adminText(json['status']),
      createdAt: adminIsoDay(json['createdAt']),
    );
  }
}

enum AdminApprovalKind { leave, deviceChange }
