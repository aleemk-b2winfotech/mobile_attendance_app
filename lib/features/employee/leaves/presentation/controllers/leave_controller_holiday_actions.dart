part of 'leave_controller.dart';

extension LeaveControllerHolidayActions on LeaveController {
  Future<void> setActiveTab(LeaveScreenTab tab) async {
    if (activeTab.value == tab) return;
    activeTab.value = tab;

    if (tab == LeaveScreenTab.holidays &&
        holidays.isEmpty &&
        holidayErrorText.value == null) {
      await loadHolidays();
    }
  }

  Future<void> loadHolidays() async {
    isHolidayLoading.value = true;
    holidayErrorText.value = null;

    try {
      final rows = await _repository.fetchHolidays(filter: _holidayApiFilter);
      holidays.assignAll(rows);
    } catch (error) {
      holidayErrorText.value = _repository.toReadableError(error);
    } finally {
      isHolidayLoading.value = false;
    }
  }

  void applyHolidayFilter(HolidayFilter filter) {
    if (holidayFilter.value == filter) return;
    holidayFilter.value = filter;
    holidays.clear();
    loadHolidays();
  }

  String get _holidayApiFilter {
    return switch (holidayFilter.value) {
      HolidayFilter.all => 'all',
      HolidayFilter.upcoming => 'future',
      HolidayFilter.past => 'past',
    };
  }
}
