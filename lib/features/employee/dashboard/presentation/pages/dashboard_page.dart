import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/widgets/centered_progress.dart';
import 'package:app/core/widgets/state_views.dart';
import 'package:app/features/employee/attendance/presentation/controllers/attendance_controller.dart';
import 'package:app/features/employee/dashboard/domain/models/dashboard_models.dart';
import 'package:app/features/employee/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:app/features/employee/dashboard/presentation/controllers/punch_flow_controller.dart';

part 'widgets/dashboard_page_top_widgets.dart';
part 'widgets/dashboard_page_summary_widgets.dart';
part 'widgets/dashboard_page_month_widgets.dart';
part 'widgets/dashboard_page_events_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, this.onOpenHistory});

  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final attendance = Get.find<AttendanceController>();
    final punchFlow = Get.find<PunchFlowController>();

    return SafeArea(
      bottom: false,
      child: Obx(() {
        final snapshot = dashboard.snapshot.value;

        if (dashboard.isLoading.value && snapshot == null) {
          return const _DashboardLoading();
        }

        if (dashboard.errorText.value != null && snapshot == null) {
          return CenterErrorView(
            message: dashboard.errorText.value!,
            onRetry: dashboard.refreshData,
          );
        }

        if (snapshot == null) {
          return const CenteredProgress();
        }

        return RefreshIndicator(
          onRefresh: dashboard.refreshData,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 60),
            children: [
              _GreetingBanner(data: snapshot),
              const SizedBox(height: 24),
              _PunchActionCard(
                status: snapshot.today,
                isBusy: attendance.isPunching.value,
                onTap: () => punchFlow.handlePunch(
                  context: context,
                  today: snapshot.today,
                ),
              ),
              const SizedBox(height: 20),
              _TodaySummaryCard(data: snapshot, onOpenHistory: onOpenHistory),
              if (snapshot.upcomingWfhDays.isNotEmpty) ...[
                const SizedBox(height: 20),
                _UpcomingWfhDays(dates: snapshot.upcomingWfhDays),
              ],
              const SizedBox(height: 20),
              _MonthlyOverview(data: snapshot.month),
            ],
          ),
        );
      }),
    );
  }
}
