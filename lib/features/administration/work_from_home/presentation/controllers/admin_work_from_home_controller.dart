import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/features/administration/management/presentation/controllers/admin_management/admin_management_base_controller.dart';
import 'package:app/features/administration/team/data/admin_user_repository.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/administration/work_from_home/data/admin_work_from_home_repository.dart';
import 'package:app/features/administration/work_from_home/domain/models/admin_wfh_form_models.dart';
import 'package:app/features/administration/work_from_home/domain/models/admin_wfh_models.dart';

class AdminWorkFromHomeController
    extends
        AdminPagedDataController<AdminWorkFromHomeRepository, AdminWfhRecord> {
  AdminWorkFromHomeController(super.repository, this._userRepository);

  final AdminUserRepository _userRepository;

  final TextEditingController search = TextEditingController();
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
      () => repository.fetchWorkFromHomePage(
        startDate: startDate.value,
        endDate: endDate.value,
        search: search.text,
        page: page.value,
        limit: 20,
      ),
    );
  }

  Future<void> applyFilters() async {
    page.value = 1;
    await load();
  }

  Future<String?> remove(AdminWfhRecord record) async {
    if (record.user.id.isEmpty || record.attendanceDate.isEmpty) return null;

    try {
      await repository.removeWorkFromHome(
        userId: record.user.id,
        startDate: record.attendanceDate,
        endDate: record.attendanceDate,
      );
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }

  Future<List<AdminUser>> fetchAssignableUsers() {
    return _userRepository.fetchUsers(role: 'EMPLOYEE', limit: 100);
  }

  Future<String?> assignWorkFromHome(AdminWfhAssignmentDraft draft) async {
    final validationError = draft.validate();
    if (validationError != null) return validationError;

    try {
      await repository.assignWorkFromHome(
        userId: draft.userId!,
        ranges: draft.toJsonRanges(),
      );
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }
}
