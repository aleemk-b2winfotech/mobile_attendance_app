import 'package:intl/intl.dart';

String formatClock(String? iso, {String fallback = '--:--'}) {
  if (iso == null || iso.isEmpty) return fallback;
  final date = DateTime.tryParse(iso)?.toLocal();
  return date == null ? fallback : DateFormat('hh:mm a').format(date);
}

String formatDate(String iso, {String pattern = 'EEE, MMM d'}) {
  final date = DateTime.tryParse(iso)?.toLocal();
  return date == null ? iso : DateFormat(pattern).format(date);
}

String formatMonth(DateTime value) => DateFormat('MMMM yyyy').format(value);

String formatMinutes(int? minutes, {String fallback = '0h 00m'}) {
  if (minutes == null) return fallback;
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return '${hour}h ${minute.toString().padLeft(2, '0')}m';
}

String formatDurationWithSeconds(Duration duration) {
  final safeDuration = duration.isNegative ? Duration.zero : duration;
  final hours = safeDuration.inHours;
  final minutes = safeDuration.inMinutes.remainder(60);
  final seconds = safeDuration.inSeconds.remainder(60);
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m '
      '${seconds.toString().padLeft(2, '0')}s';
}

String formatRelative(String iso) {
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '';

  final gap = DateTime.now().difference(date);
  if (gap.inMinutes < 1) return 'Just now';
  if (gap.inMinutes < 60) return '${gap.inMinutes} min ago';
  if (gap.inHours < 24) return '${gap.inHours} hrs ago';
  if (gap.inDays < 7) return '${gap.inDays} days ago';
  return DateFormat('MMM d, yyyy').format(date);
}

String sentenceCaseStatus(String raw) {
  final key = raw.trim();
  if (key.isEmpty) return key;

  switch (key.toLowerCase()) {
    case 'halfday':
    case 'half_day':
      return 'Half Day';
    case 'onleave':
    case 'on_leave':
      return 'Leave';
    case 'weeklyoff':
    case 'weekly_off':
      return 'Weekly Off';
    default:
      return '${key[0].toUpperCase()}${key.substring(1).toLowerCase()}';
  }
}

String attendanceDescriptor(String state, {int? workedMinutes}) {
  switch (state.toLowerCase()) {
    case 'present':
    case 'completed':
      return 'Full Day';
    case 'working':
      return 'Today';
    case 'halfday':
    case 'half_day':
      return workedMinutes != null && workedMinutes <= 300
          ? 'Short Hours'
          : 'Half Day';
    case 'absent':
      return 'Absent';
    case 'holiday':
      return 'Holiday';
    case 'weeklyoff':
    case 'weekly_off':
      return 'Weekly Off';
    case 'onleave':
    case 'on_leave':
      return 'On Leave';
    default:
      return sentenceCaseStatus(state);
  }
}

String inferLeaveType(String reason) {
  final normalized = reason.toLowerCase();
  if (normalized.startsWith('[sick leave]') || normalized.contains('sick')) {
    return 'Sick Leave';
  }
  if (normalized.startsWith('[Optional Leave]') ||
      normalized.contains('optional')) {
    return 'Optional Leave';
  }
  if (normalized.startsWith('[loss of Pay Leave]') ||
      normalized.contains('loss of pay')) {
    return 'Loss of Pay Leave';
  }
  if (normalized.startsWith('[paid leave]') || normalized.contains('paid')) {
    return 'Paid Leave';
  }
  return 'Leave Request';
}

String stripLeavePrefix(String reason) {
  if (!reason.startsWith('[') || !reason.contains(']')) return reason;
  final split = reason.indexOf(']');
  if (split <= 0 || split == reason.length - 1) return reason;
  return reason.substring(split + 1).trimLeft();
}

String primaryRoleTitle(List<String> roles) {
  if (roles.contains('ADMIN')) return 'ADMIN + EMPLOYEE';
  if (roles.contains('MANAGER')) {
    return 'MANAGER + EMPLOYEE';
  }
  return 'Employee';
}
