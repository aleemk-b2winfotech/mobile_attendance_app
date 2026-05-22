import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/features/administration/analytics/data/admin_analytics_repository.dart';
import 'package:app/features/administration/analytics/domain/models/admin_analytics_models.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management/admin_management_base_controller.dart';

class AdminAnalyticsController
    extends
        AdminPagedDataController<AdminAnalyticsRepository, AdminAnalyticsRow> {
  AdminAnalyticsController(super.repository);

  final TextEditingController search = TextEditingController();
  final Rx<AdminAnalyticsAggregate> aggregate =
      const AdminAnalyticsAggregate.empty().obs;
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
  Future<void> load() async {
    isLoading.value = true;
    errorText.value = null;

    try {
      final result = await repository.fetchAttendanceOverviewResult(
        startDate: startDate.value,
        endDate: endDate.value,
        search: search.text,
        page: page.value,
        limit: 20,
      );
      rows.assignAll(result.rows);
      aggregate.value = result.aggregate;
      meta.value = result.meta;
    } catch (error) {
      errorText.value = repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters() async {
    page.value = 1;
    await load();
  }
}
