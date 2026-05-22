import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/utils/status_styles.dart';
import 'package:app/core/widgets/app_header.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/core/widgets/sheet_padding.dart';
import 'package:app/core/widgets/state_views.dart';
import 'package:app/core/widgets/status_chip.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';
import 'package:app/features/employee/leaves/presentation/controllers/leave_controller.dart';

part 'widgets/leaves_page_filters_widgets.dart';
part 'widgets/leaves_page_request_tile_widgets.dart';
part 'widgets/leaves_page_misc_widgets.dart';
part 'widgets/leaves_page_holidays_widgets.dart';
part 'widgets/leaves_page_form_widgets.dart';
part 'widgets/leaves_page_thread_widgets.dart';

class LeavesPage extends GetView<LeaveController> {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rangeText = controller.totalRequests.value == 0
          ? null
          : '${controller.firstVisibleIndex}-${controller.lastVisibleIndex} of ${controller.totalRequests.value}';

      final emptyText = controller.statusFilter.value == null
          ? 'No leave requests yet. Tap New leave to create one.'
          : 'No ${sentenceCaseStatus(controller.statusFilter.value!).toLowerCase()} leave requests found.';

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton:
            controller.activeTab.value == LeaveScreenTab.leaves
            ? _NewLeaveButton(
                onTap: controller.isSubmitting.value
                    ? null
                    : () => _openCreateRequestSheet(context),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppHeader(title: 'Time Off', showDivider: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                child: _LeaveTabSwitcher(
                  selectedTab: controller.activeTab.value,
                  onChanged: controller.setActiveTab,
                ),
              ),
              Expanded(
                child: controller.activeTab.value == LeaveScreenTab.holidays
                    ? _HolidaysTab(
                        holidays: controller.holidays,
                        selectedFilter: controller.holidayFilter.value,
                        isLoading: controller.isHolidayLoading.value,
                        errorText: controller.holidayErrorText.value,
                        onFilterChanged: controller.applyHolidayFilter,
                        onRefresh: controller.loadHolidays,
                      )
                    : controller.errorText.value != null &&
                          controller.requests.isEmpty &&
                          !controller.isLoading.value
                    ? CenterErrorView(
                        message: controller.errorText.value!,
                        onRetry: controller.loadRequests,
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadRequests(),
                        color: AppColors.primary,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
                          children: [
                            if (controller.showSuccessBanner.value) ...[
                              _SuccessBanner(
                                onDismiss: () =>
                                    controller.showSuccessBanner.value = false,
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              'Recent Requests',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (rangeText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  rangeText,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            _LeaveFilterStrip(
                              selectedStatus: controller.statusFilter.value,
                              isLoading: controller.isLoading.value,
                              onChanged: controller.applyStatusFilter,
                            ),
                            if (controller.isLoading.value &&
                                controller.requests.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: const LinearProgressIndicator(
                                  minHeight: 4,
                                  color: AppColors.primaryDark,
                                  backgroundColor: AppColors.border,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (controller.isLoading.value &&
                                controller.requests.isEmpty)
                              const _LeaveSkeletonList()
                            else if (controller.requests.isEmpty)
                              EmptyInfoCard(
                                title: 'No Requests',
                                message: emptyText,
                                icon: AppIcons.calendarRemove,
                              )
                            else
                              ...controller.requests.map(
                                (request) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _LeaveRequestTile(
                                    request: request,
                                    isCancelling: controller.isCancelling(
                                      request.id,
                                    ),
                                    onCancel:
                                        request.status.toUpperCase() ==
                                            'PENDING'
                                        ? () => _confirmCancel(context, request)
                                        : null,
                                    onOpenThread: () =>
                                        _openThreadSheet(context, request),
                                  ),
                                ),
                              ),
                            if (controller.totalRequests.value > 0) ...[
                              const SizedBox(height: 8),
                              _PaginationCard(
                                currentPage: controller.currentPage.value,
                                totalPages: controller.totalPageCount,
                                isLoading: controller.isLoading.value,
                                onPrevious: controller.hasPreviousPage
                                    ? () {
                                        controller.loadPreviousPage();
                                      }
                                    : null,
                                onNext: controller.hasNextPage
                                    ? () {
                                        controller.loadNextPage();
                                      }
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _confirmCancel(
    BuildContext context,
    LeaveRequest request,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Leave Request'),
          content: const Text(
            'Do you want to withdraw this pending leave request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Request'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Cancel Request'),
            ),
          ],
        );
      },
    );

    if (accepted != true || !context.mounted) return;

    final error = await controller.cancelRequest(request.id);
    if (!context.mounted) return;

    AppToast.show(error ?? 'Leave request cancelled.', isError: error != null);
  }

  Future<void> _openCreateRequestSheet(BuildContext context) async {
    controller.clearSubmitError();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'New Leave Request',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose your leave type, select the dates, and send the request for approval.',
                      style: Theme.of(sheetContext).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 18),
                    _LeaveForm(
                      onSubmitted: () {
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    controller.clearSubmitError();
  }

  Future<void> _openThreadSheet(
    BuildContext context,
    LeaveRequest request,
  ) async {
    controller.loadThread(request.id, force: true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LeaveThreadSheet(request: request),
    );
  }
}
