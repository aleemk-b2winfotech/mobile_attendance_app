import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminHoliday {
  AdminHoliday({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.isDeleted = false,
  });

  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String description;
  final bool isDeleted;

  factory AdminHoliday.fromJson(Map<String, dynamic> json) {
    return AdminHoliday(
      id: adminText(json['id']),
      title: adminText(json['title'], fallback: 'Holiday'),
      startDate: adminIsoDay(json['startDate']),
      endDate: adminIsoDay(json['endDate']),
      description: adminText(json['description']),
      isDeleted: json['isDeleted'] == true,
    );
  }
}

class AdminHolidayHistoryEntry {
  const AdminHolidayHistoryEntry({
    required this.action,
    required this.reason,
    required this.actorName,
    required this.createdAt,
  });

  final String action;
  final String reason;
  final String actorName;
  final String createdAt;

  factory AdminHolidayHistoryEntry.fromJson(Map<String, dynamic> json) {
    final actor = adminUserMap(json['actor']);
    return AdminHolidayHistoryEntry(
      action: adminText(json['action'], fallback: 'Change'),
      reason: adminText(json['reason']),
      actorName: actor['fullName'] ?? '',
      createdAt: adminText(json['createdAt']),
    );
  }
}

class AdminHolidayDraft {
  const AdminHolidayDraft({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String? reason;

  String? validate({required bool isEditing}) {
    if (title.trim().isEmpty) return 'Title is required.';
    if (isEditing && (reason == null || reason!.trim().isEmpty)) {
      return 'Change reason is required.';
    }

    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null || end.isBefore(start)) {
      return 'End date must be on or after the start date.';
    }

    return null;
  }
}
