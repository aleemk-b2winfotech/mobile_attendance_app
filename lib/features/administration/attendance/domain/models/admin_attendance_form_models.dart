enum AdminAttendanceOverrideStatus {
  present('PRESENT', 'Present'),
  halfDay('HALF_DAY', 'Half day'),
  absent('ABSENT', 'Absent'),
  leave('ON_LEAVE', 'Leave');

  const AdminAttendanceOverrideStatus(this.value, this.label);

  final String value;
  final String label;

  bool get requiresPunchTimes =>
      this == AdminAttendanceOverrideStatus.present ||
      this == AdminAttendanceOverrideStatus.halfDay;

  static AdminAttendanceOverrideStatus fromValue(String value) {
    return switch (value) {
      'HALF_DAY' => AdminAttendanceOverrideStatus.halfDay,
      'ABSENT' => AdminAttendanceOverrideStatus.absent,
      'ON_LEAVE' => AdminAttendanceOverrideStatus.leave,
      _ => AdminAttendanceOverrideStatus.present,
    };
  }

  static AdminAttendanceOverrideStatus fromAttendanceState(String state) {
    return switch (state) {
      'halfDay' => AdminAttendanceOverrideStatus.halfDay,
      'absent' => AdminAttendanceOverrideStatus.absent,
      'onLeave' => AdminAttendanceOverrideStatus.leave,
      _ => AdminAttendanceOverrideStatus.present,
    };
  }
}

class AdminAttendanceOverrideDraft {
  const AdminAttendanceOverrideDraft({
    required this.userId,
    required this.date,
    required this.status,
    required this.reason,
    this.overridePunchInAt,
    this.overridePunchOutAt,
  });

  final String userId;
  final String date;
  final AdminAttendanceOverrideStatus status;
  final String reason;
  final String? overridePunchInAt;
  final String? overridePunchOutAt;

  String? validate({required bool requireReason}) {
    if (userId.isEmpty || date.isEmpty) return 'Attendance record is invalid.';
    if (!requireReason) return null;
    if (reason.trim().isEmpty) return 'Reason is required.';
    if (!status.requiresPunchTimes) return null;

    final punchIn = overridePunchInAt?.trim() ?? '';
    final punchOut = overridePunchOutAt?.trim() ?? '';
    if (punchIn.isEmpty || punchOut.isEmpty) {
      return 'Punch in and out times are required for this status.';
    }

    final punchInTime = DateTime.tryParse(punchIn);
    final punchOutTime = DateTime.tryParse(punchOut);
    if (punchInTime == null || punchOutTime == null) {
      return 'Punch times are invalid.';
    }
    if (!punchOutTime.isAfter(punchInTime)) {
      return 'Punch out time must be after punch in time.';
    }

    return null;
  }
}
