class AdminWfhRangeDraft {
  const AdminWfhRangeDraft({required this.startDate, required this.endDate});

  final String startDate;
  final String endDate;

  AdminWfhRangeDraft copyWith({String? startDate, String? endDate}) {
    return AdminWfhRangeDraft(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, String> toJson() {
    return <String, String>{'startDate': startDate, 'endDate': endDate};
  }

  String? validate() {
    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null || end.isBefore(start)) {
      return 'Each range must have an end date on or after the start date.';
    }
    return null;
  }
}

class AdminWfhAssignmentDraft {
  const AdminWfhAssignmentDraft({required this.userId, required this.ranges});

  final String? userId;
  final List<AdminWfhRangeDraft> ranges;

  String? validate() {
    if (userId == null || userId!.trim().isEmpty) {
      return 'Choose an employee.';
    }
    if (ranges.isEmpty) return 'Add at least one date range.';

    for (final range in ranges) {
      final error = range.validate();
      if (error != null) return error;
    }

    return null;
  }

  List<Map<String, String>> toJsonRanges() {
    return ranges.map((range) => range.toJson()).toList(growable: false);
  }
}
