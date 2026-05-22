import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/utils/status_styles.dart';
import 'package:app/core/widgets/app_header.dart';
import 'package:app/core/widgets/state_views.dart';
import 'package:app/features/employee/attendance/domain/models/attendance_models.dart';
import 'package:app/features/employee/attendance/presentation/controllers/attendance_controller.dart';

part 'widgets/attendance_page_overview_widgets.dart';
part 'widgets/attendance_page_record_widgets.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final overview = controller.overview.value;
      final selectedMonth = controller.month.value;
      final rows = controller.visibleDays;
      final summary = controller.summaryForDays(rows);
      final now = DateTime(DateTime.now().year, DateTime.now().month);

      final canGoNext =
          selectedMonth.year < now.year ||
          (selectedMonth.year == now.year && selectedMonth.month < now.month);

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppHeader(title: 'Attendance History', showDivider: true),
              Expanded(
                child: controller.isLoading.value && overview == null
                    ? const _AttendanceLoading()
                    : controller.errorText.value != null && overview == null
                    ? CenterErrorView(
                        message: controller.errorText.value!,
                        onRetry: controller.loadOverview,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                        children: [
                          _SummaryCards(summary: summary),
                          const SizedBox(height: 10),
                          _MonthSelector(
                            selectedMonth: selectedMonth,
                            canGoNext: canGoNext,
                            onPrevious: () => controller.changeMonth(
                              DateTime(
                                selectedMonth.year,
                                selectedMonth.month - 1,
                              ),
                            ),
                            onNext: () => controller.changeMonth(
                              DateTime(
                                selectedMonth.year,
                                selectedMonth.month + 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _StatusFilterStrip(
                              selectedStatuses: controller
                                  .selectedStatuses
                                  .value
                                  .toSet(),
                              onToggle: controller.toggleStatus,
                              onClear: controller.clearFilters,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (rows.isEmpty)
                            const EmptyInfoCard(
                              title: 'End of Records',
                              message:
                                  'No more attendance records found. Try adjusting filters to see more results.',
                            )
                          else
                            ...rows.map(
                              (day) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12,
                                  left: 8,
                                  right: 8,
                                ),
                                child: _AttendanceRecordCard(day: day),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
