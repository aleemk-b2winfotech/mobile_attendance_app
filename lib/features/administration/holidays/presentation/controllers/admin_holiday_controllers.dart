import 'package:get/get.dart';

import 'package:app/features/administration/holidays/data/admin_holiday_repository.dart';
import 'package:app/features/administration/holidays/domain/models/admin_holiday_models.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management/admin_management_base_controller.dart';

class AdminHolidaysController
    extends AdminDataController<AdminHolidayRepository, AdminHoliday> {
  AdminHolidaysController(super.repository);

  final RxBool includeDeleted = false.obs;
  final RxString startDate = adminMonthStart().obs;
  final RxString endDate = adminMonthEnd().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<void> load() {
    return runLoad(
      () => repository.fetchHolidayRows(
        startDate: startDate.value,
        endDate: endDate.value,
        includeDeleted: includeDeleted.value,
      ),
    );
  }

  Future<void> setIncludeDeleted(bool value) async {
    includeDeleted.value = value;
    await load();
  }

  Future<String?> deleteHoliday(AdminHoliday holiday, String reason) async {
    try {
      await repository.deleteHoliday(id: holiday.id, reason: reason);
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }

  Future<List<AdminHolidayHistoryEntry>> history(AdminHoliday holiday) {
    return repository.fetchHolidayHistoryRows(holiday.id);
  }

  Future<String?> saveHoliday({
    required AdminHolidayDraft draft,
    AdminHoliday? holiday,
  }) async {
    final isEditing = holiday != null;
    final validationError = draft.validate(isEditing: isEditing);
    if (validationError != null) return validationError;

    try {
      if (isEditing) {
        await repository.updateHoliday(
          id: holiday.id,
          title: draft.title.trim(),
          description: draft.description.trim(),
          startDate: draft.startDate,
          endDate: draft.endDate,
          reason: draft.reason?.trim() ?? '',
        );
      } else {
        await repository.createHoliday(
          title: draft.title.trim(),
          description: draft.description.trim(),
          startDate: draft.startDate,
          endDate: draft.endDate,
        );
      }
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }
}
