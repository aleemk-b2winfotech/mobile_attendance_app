import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/services/map_launcher_service.dart';
import 'package:app/features/administration/attendance/domain/models/admin_attendance_models.dart';
import 'package:app/features/administration/attendance/data/admin_attendance_repository.dart';
import 'package:app/features/administration/attendance/domain/models/admin_attendance_form_models.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management/admin_management_base_controller.dart';

class AdminAttendanceRecordsController
    extends
        AdminPagedDataController<
          AdminAttendanceRepository,
          AdminAttendanceRecord
        > {
  AdminAttendanceRecordsController(super.repository);

  final TextEditingController search = TextEditingController();
  final RxString status = 'all'.obs;
  final RxString startDate = adminMonthStart().obs;
  final RxString endDate = adminMonthEnd().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    search.dispose();
    super.onClose();
  }

  @override
  Future<void> load() {
    return runPagedLoad(
      () => repository.fetchAttendanceRecordPage(
        startDate: startDate.value,
        endDate: endDate.value,
        status: status.value,
        search: search.text,
        page: page.value,
        limit: 20,
      ),
    );
  }

  Future<void> applyStatus(String value) async {
    status.value = value;
    page.value = 1;
    await load();
  }

  Future<void> applyFilters() async {
    page.value = 1;
    await load();
  }

  Future<String?> upsertRegularization(
    AdminAttendanceOverrideDraft draft,
  ) async {
    final validationError = draft.validate(requireReason: true);
    if (validationError != null) return validationError;

    try {
      await repository.upsertAttendanceRegularization(
        userId: draft.userId,
        date: draft.date,
        overrideStatus: draft.status.value,
        reason: draft.reason.trim(),
        overridePunchInAt: draft.overridePunchInAt,
        overridePunchOutAt: draft.overridePunchOutAt,
      );
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }

  Future<String?> deleteRegularization(
    AdminAttendanceOverrideDraft draft,
  ) async {
    final validationError = draft.validate(requireReason: false);
    if (validationError != null) return validationError;

    try {
      await repository.deleteAttendanceRegularization(
        userId: draft.userId,
        date: draft.date,
      );
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }

  Future<String?> openLocationInMaps({
    required double latitude,
    required double longitude,
  }) async {
    final opened = await Get.find<MapLauncherService>().openCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
    return opened ? null : 'Unable to open maps.';
  }
}
