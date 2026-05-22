import 'package:app/features/employee/shared/domain/models/employee_user_summary.dart';

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.workingDayCount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.approvedStartDate,
    this.approvedEndDate,
    this.approvedWorkingDayCount,
    this.actionNote,
    this.actionAt,
    this.actionBy,
    this.user,
  });

  final String id;
  final String userId;
  final String startDate;
  final String endDate;
  final int workingDayCount;
  final String reason;
  final String status;
  final String createdAt;
  final String? approvedStartDate;
  final String? approvedEndDate;
  final int? approvedWorkingDayCount;
  final String? actionNote;
  final String? actionAt;
  final EmployeeUserSummary? actionBy;
  final EmployeeUserSummary? user;

  String get effectiveStartDate => approvedStartDate ?? startDate;

  String get effectiveEndDate => approvedEndDate ?? endDate;

  int get effectiveWorkingDayCount =>
      approvedWorkingDayCount ?? workingDayCount;

  bool get hasApprovedDateOverride {
    return approvedStartDate != null &&
        approvedEndDate != null &&
        (approvedStartDate != startDate ||
            approvedEndDate != endDate ||
            approvedWorkingDayCount != workingDayCount);
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      startDate: _toIsoDay(json['startDate']),
      endDate: _toIsoDay(json['endDate']),
      workingDayCount: json['workingDayCount'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      approvedStartDate: _toNullableIsoDay(json['approvedStartDate']),
      approvedEndDate: _toNullableIsoDay(json['approvedEndDate']),
      approvedWorkingDayCount: json['approvedWorkingDayCount'] as int?,
      actionNote: json['actionNote'] as String?,
      actionAt: json['actionAt'] as String?,
      actionBy: json['actionBy'] is Map<String, dynamic>
          ? EmployeeUserSummary.fromJson(json['actionBy'])
          : null,
      user: json['user'] is Map<String, dynamic>
          ? EmployeeUserSummary.fromJson(json['user'])
          : null,
    );
  }
}

class DeviceChangeRequest {
  DeviceChangeRequest({
    required this.id,
    required this.userId,
    required this.requestedDeviceId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.currentDeviceIdSnapshot,
    this.actionNote,
    this.actionAt,
    this.actionBy,
  });

  final String id;
  final String userId;
  final String requestedDeviceId;
  final String reason;
  final String status;
  final String createdAt;
  final String? currentDeviceIdSnapshot;
  final String? actionNote;
  final String? actionAt;
  final EmployeeUserSummary? actionBy;

  factory DeviceChangeRequest.fromJson(Map<String, dynamic> json) {
    return DeviceChangeRequest(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      requestedDeviceId: json['requestedDeviceId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      currentDeviceIdSnapshot: json['currentDeviceIdSnapshot'] as String?,
      actionNote: json['actionNote'] as String?,
      actionAt: json['actionAt'] as String?,
      actionBy: json['actionBy'] is Map<String, dynamic>
          ? EmployeeUserSummary.fromJson(json['actionBy'])
          : null,
    );
  }
}

class HolidayItem {
  HolidayItem({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String? description;

  factory HolidayItem.fromJson(Map<String, dynamic> json) {
    return HolidayItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Holiday',
      startDate: _toIsoDay(json['startDate']),
      endDate: _toIsoDay(json['endDate']),
      description: json['description'] as String?,
    );
  }
}

class LeaveThread {
  LeaveThread({required this.leaveRequestId, required this.messages});

  final String leaveRequestId;
  final List<LeaveThreadMessage> messages;

  factory LeaveThread.fromJson(Map<String, dynamic> json) {
    return LeaveThread(
      leaveRequestId: json['leaveRequestId'] as String? ?? '',
      messages: (json['messages'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LeaveThreadMessage.fromJson)
          .toList(growable: false),
    );
  }
}

class LeaveThreadMessage {
  LeaveThreadMessage({
    required this.id,
    required this.leaveRequestId,
    required this.actorUserId,
    required this.messageType,
    required this.createdAt,
    this.message,
    this.proposedStartDate,
    this.proposedEndDate,
    this.proposedWorkingDayCount,
    this.acceptedThreadMessageId,
    this.actor,
    this.acceptedThreadMessage,
  });

  final String id;
  final String leaveRequestId;
  final String actorUserId;
  final String messageType;
  final String createdAt;
  final String? message;
  final String? proposedStartDate;
  final String? proposedEndDate;
  final int? proposedWorkingDayCount;
  final String? acceptedThreadMessageId;
  final LeaveThreadActor? actor;
  final LeaveThreadAcceptedMessage? acceptedThreadMessage;

  bool get isProposal => messageType == 'PROPOSAL';

  bool get hasProposedDates =>
      proposedStartDate != null && proposedEndDate != null;

  factory LeaveThreadMessage.fromJson(Map<String, dynamic> json) {
    return LeaveThreadMessage(
      id: json['id'] as String? ?? '',
      leaveRequestId: json['leaveRequestId'] as String? ?? '',
      actorUserId: json['actorUserId'] as String? ?? '',
      messageType: json['messageType'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      message: json['message'] as String?,
      proposedStartDate: _toNullableIsoDay(json['proposedStartDate']),
      proposedEndDate: _toNullableIsoDay(json['proposedEndDate']),
      proposedWorkingDayCount: json['proposedWorkingDayCount'] as int?,
      acceptedThreadMessageId: json['acceptedThreadMessageId'] as String?,
      actor: json['actor'] is Map<String, dynamic>
          ? LeaveThreadActor.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
      acceptedThreadMessage: LeaveThreadAcceptedMessage.fromJsonOrNull(
        json['acceptedThreadMessage'],
      ),
    );
  }
}

class LeaveThreadActor {
  LeaveThreadActor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;

  factory LeaveThreadActor.fromJson(Map<String, dynamic> json) {
    return LeaveThreadActor(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class LeaveThreadAcceptedMessage {
  const LeaveThreadAcceptedMessage({required this.id, required this.createdAt});

  final String id;
  final String createdAt;

  static LeaveThreadAcceptedMessage? fromJsonOrNull(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return LeaveThreadAcceptedMessage(
      id: value['id'] as String? ?? '',
      createdAt: value['createdAt'] as String? ?? '',
    );
  }
}

String _toIsoDay(Object? value) {
  final date = value?.toString() ?? '';
  if (date.length <= 10) return date;
  return date.substring(0, 10);
}

String? _toNullableIsoDay(Object? value) {
  final date = _toIsoDay(value);
  return date.isEmpty ? null : date;
}
