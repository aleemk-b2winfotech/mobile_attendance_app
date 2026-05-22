class AttendanceOverview {
  AttendanceOverview({
    required this.range,
    required this.summary,
    required this.days,
  });

  final AttendanceRange range;
  final AttendanceSummary summary;
  final List<AttendanceDay> days;

  factory AttendanceOverview.fromJson(Map<String, dynamic> json) {
    return AttendanceOverview(
      range: AttendanceRange.fromJson(json['range'] as Map<String, dynamic>),
      summary: AttendanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      days: (json['days'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AttendanceDay.fromJson)
          .toList(growable: false),
    );
  }
}

class AttendanceRange {
  AttendanceRange({
    required this.startDate,
    required this.endDate,
    required this.appliedEndDate,
    required this.currentDateExcluded,
  });

  final String startDate;
  final String endDate;
  final String appliedEndDate;
  final bool currentDateExcluded;

  factory AttendanceRange.fromJson(Map<String, dynamic> json) {
    return AttendanceRange(
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      appliedEndDate: json['appliedEndDate'] as String,
      currentDateExcluded: json['currentDateExcluded'] as bool? ?? false,
    );
  }
}

class AttendanceSummary {
  AttendanceSummary({
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

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
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

class AttendanceDay {
  AttendanceDay({
    required this.date,
    required this.dayType,
    required this.attendanceState,
    required this.flags,
    this.punchInAt,
    this.punchOutAt,
    this.workedMinutes,
    this.holiday,
    this.leaveRequest,
    this.regularization,
  });

  final String date;
  final String dayType;
  final String attendanceState;
  final String? punchInAt;
  final String? punchOutAt;
  final int? workedMinutes;
  final List<String> flags;
  final AttendanceLinkedRecord? holiday;
  final AttendanceLinkedRecord? leaveRequest;
  final AttendanceLinkedRecord? regularization;

  bool get hasRegularizationLink => regularization?.hasId ?? false;

  bool get hasLeaveLink => leaveRequest?.hasId ?? false;

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    return AttendanceDay(
      date: json['date'] as String,
      dayType: json['dayType'] as String,
      attendanceState: json['attendanceState'] as String,
      punchInAt: json['punchInAt'] as String?,
      punchOutAt: json['punchOutAt'] as String?,
      workedMinutes: json['workedMinutes'] as int?,
      flags: (json['flags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      holiday: AttendanceLinkedRecord.fromJsonOrNull(json['holiday']),
      leaveRequest: AttendanceLinkedRecord.fromJsonOrNull(json['leaveRequest']),
      regularization: AttendanceLinkedRecord.fromJsonOrNull(
        json['regularization'],
      ),
    );
  }
}

class AttendanceLinkedRecord {
  const AttendanceLinkedRecord({required this.id});

  final String id;

  bool get hasId => id.isNotEmpty;

  static AttendanceLinkedRecord? fromJsonOrNull(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return AttendanceLinkedRecord(id: value['id']?.toString().trim() ?? '');
  }
}

class AttendanceFilterState {
  const AttendanceFilterState({this.statuses = const <String>{}});

  final Set<String> statuses;

  static const Map<String, String> labels = <String, String>{
    'present': 'Present',
    'absent': 'Absent',
    'halfDay': 'Half Day',
    'overtime': 'Overtime',
    'regularized': 'Overridden',
  };

  bool get hasFilter => statuses.isNotEmpty;

  AttendanceFilterState copyWith({Set<String>? statuses}) {
    return AttendanceFilterState(statuses: statuses ?? this.statuses);
  }
}
