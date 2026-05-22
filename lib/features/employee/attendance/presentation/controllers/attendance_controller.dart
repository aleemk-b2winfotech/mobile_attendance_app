import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/features/employee/attendance/data/attendance_repository.dart';
import 'package:app/features/employee/attendance/domain/models/attendance_models.dart';

class AttendanceController extends GetxController {
  AttendanceController(this._repository);

  final AttendanceRepository _repository;

  final Rxn<AttendanceOverview> overview = Rxn<AttendanceOverview>();
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;

  final RxnString errorText = RxnString();
  final RxnString punchError = RxnString();
  final RxnString punchSuccess = RxnString();

  final Rx<DateTime> month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;
  final Rx<List<String>> selectedStatuses = Rx<List<String>>(<String>[]);

  @override
  void onInit() {
    super.onInit();
    loadOverview();
  }

  Future<void> loadOverview({String? startDate, String? endDate}) async {
    isLoading.value = true;
    errorText.value = null;

    final start =
        startDate ??
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(month.value.year, month.value.month, 1));
    final end =
        endDate ??
        DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(month.value.year, month.value.month + 1, 0));

    try {
      overview.value = await _repository.fetchOverview(
        startDate: start,
        endDate: end,
      );
    } catch (error) {
      errorText.value = _repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(DateTime nextMonth) {
    month.value = DateTime(nextMonth.year, nextMonth.month);
    overview.value = null;
    loadOverview();
  }

  void toggleStatus(String status) {
    final next = <String>{...selectedStatuses.value};
    if (!next.add(status)) {
      next.remove(status);
    }
    selectedStatuses.value = next.toList(growable: false);
  }

  void clearFilters() {
    if (selectedStatuses.value.isEmpty) return;
    selectedStatuses.value = <String>[];
  }

  List<AttendanceDay> get visibleDays {
    final statuses = selectedStatuses.value.toSet();
    final rows =
        (overview.value?.days ?? const <AttendanceDay>[])
            .where(
              (day) => !{
                'holiday',
                'weeklyOff',
                'onLeave',
              }.contains(day.attendanceState),
            )
            .toList(growable: false)
          ..sort((left, right) => right.date.compareTo(left.date));

    if (statuses.isEmpty) return rows;

    return rows
        .where((day) {
          for (final status in statuses) {
            if (_matchStatus(day, status)) return true;
          }
          return false;
        })
        .toList(growable: false);
  }

  AttendanceSummary? get visibleSummary {
    return summaryForDays(visibleDays);
  }

  AttendanceSummary? summaryForDays(List<AttendanceDay> days) {
    final monthly = overview.value?.summary;
    if (monthly == null) return null;

    var present = 0;
    var half = 0;
    var absent = 0;

    for (final day in days) {
      switch (day.attendanceState) {
        case 'present':
        case 'regularized':
        case 'completed':
          present++;
          break;
        case 'halfDay':
          half++;
          break;
        case 'absent':
          absent++;
          break;
      }
    }

    final tracked = present + half + absent;
    final percentage = tracked == 0
        ? 0.0
        : ((present + (half * 0.5)) / tracked) * 100;

    return AttendanceSummary(
      presentDays: present,
      halfDays: half,
      absentDays: absent,
      leaveDays: monthly.leaveDays,
      holidayDays: monthly.holidayDays,
      weeklyOffDays: monthly.weeklyOffDays,
      attendancePercentage: percentage,
    );
  }

  Future<bool> punchIn({
    double? latitude,
    double? longitude,
    String? todayPlan,
  }) async {
    isPunching.value = true;
    punchError.value = null;
    punchSuccess.value = null;

    try {
      await _repository.punchIn(
        latitude: latitude,
        longitude: longitude,
        todayPlan: todayPlan,
      );
      punchSuccess.value = 'Punched in successfully';
      return true;
    } catch (error) {
      punchError.value = _repository.toReadableError(error);
      return false;
    } finally {
      isPunching.value = false;
    }
  }

  Future<bool> punchOut({
    double? latitude,
    double? longitude,
    String? report,
  }) async {
    isPunching.value = true;
    punchError.value = null;
    punchSuccess.value = null;

    try {
      await _repository.punchOut(
        latitude: latitude,
        longitude: longitude,
        report: report,
      );
      punchSuccess.value = 'Punched out successfully';
      return true;
    } catch (error) {
      punchError.value = _repository.toReadableError(error);
      return false;
    } finally {
      isPunching.value = false;
    }
  }

  bool _matchStatus(AttendanceDay day, String filter) {
    switch (filter) {
      case 'present':
        return day.attendanceState == 'present' ||
            day.attendanceState == 'regularized';
      case 'absent':
        return day.attendanceState == 'absent';
      case 'halfDay':
        return day.attendanceState == 'halfDay';
      case 'overtime':
        return (day.workedMinutes ?? 0) > 480;
      case 'regularized':
        return day.hasRegularizationLink ||
            day.attendanceState == 'regularized';
      default:
        return false;
    }
  }
}
