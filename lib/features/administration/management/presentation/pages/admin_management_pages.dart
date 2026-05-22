import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/utils/status_styles.dart';
import 'package:app/core/widgets/app_header.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/core/widgets/button_spinner.dart';
import 'package:app/core/widgets/centered_progress.dart';
import 'package:app/core/widgets/sheet_padding.dart';
import 'package:app/core/widgets/state_views.dart';
import 'package:app/core/widgets/status_chip.dart';
import 'package:app/features/administration/analytics/domain/models/admin_analytics_models.dart';
import 'package:app/features/administration/approvals/domain/models/admin_approval_models.dart';
import 'package:app/features/administration/attendance/domain/models/admin_attendance_form_models.dart';
import 'package:app/features/administration/attendance/domain/models/admin_attendance_models.dart';
import 'package:app/features/administration/holidays/domain/models/admin_holiday_models.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management_controller.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/administration/work_from_home/domain/models/admin_wfh_form_models.dart';
import 'package:app/features/administration/work_from_home/domain/models/admin_wfh_models.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

part 'widgets/admin_management_forms.dart';
part 'widgets/admin_management_frame_widgets.dart';
part 'widgets/admin_management_date_filter.dart';
part '../../../analytics/presentation/pages/widgets/admin_management_analytics_widgets.dart';
part '../../../approvals/presentation/pages/widgets/admin_management_approval_widgets.dart';
part '../../../approvals/presentation/pages/widgets/admin_management_leave_thread_page.dart';
part '../../../approvals/presentation/pages/widgets/admin_management_leave_thread_widgets.dart';
part '../../../attendance/presentation/pages/widgets/admin_management_attendance_filter.dart';
part '../../../attendance/presentation/pages/widgets/admin_management_attendance_widgets.dart';
part '../../../holidays/presentation/pages/widgets/admin_management_holiday_filter.dart';
part '../../../holidays/presentation/pages/widgets/admin_management_holiday_widgets.dart';
part '../../../work_from_home/presentation/pages/widgets/admin_management_wfh_widgets.dart';
part 'widgets/admin_management_shared_widgets.dart';

class AdminAttendanceRecordsPage extends StatelessWidget {
  const AdminAttendanceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminAttendanceRecordsController>();
    return Obx(() {
      final rows = controller.rows.toList(growable: false);
      return _AdminPageFrame(
        title: 'Attendance',
        child: Column(
          children: [
            _AttendanceFilterBar(
              startDate: controller.startDate.value,
              endDate: controller.endDate.value,
              status: controller.status.value,
              onApply: (startDate, endDate, status) async {
                controller.startDate.value = startDate;
                controller.endDate.value = endDate;
                controller.status.value = status;
                await controller.applyFilters();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: TextField(
                controller: controller.search,
                decoration: const InputDecoration(
                  hintText: 'Search employee',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: (_) => controller.applyFilters(),
              ),
            ),
            Expanded(
              child: _PagedBody(
                loading: controller.isLoading.value,
                error: controller.errorText.value,
                isEmpty: rows.isEmpty,
                onRetry: controller.load,
                emptyTitle: 'No attendance records',
                emptyMessage: 'Try another date range or status.',
                child: RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    itemCount: rows.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == rows.length) {
                        return _Pager(
                          meta: controller.meta.value,
                          onPage: controller.goToPage,
                        );
                      }
                      return _AttendanceRecordCard(
                        record: rows[index],
                        controller: controller,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  static const double _summaryPullThreshold = 54;
  static const double _summaryPullFactor = 0.2;
  static const double _summarySettleProgress = 0.5;

  bool _showSummary = false;
  double _summaryPullExtent = 0;
  final ScrollController _analyticsScroll = ScrollController();

  @override
  void dispose() {
    _analyticsScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminAnalyticsController>();
    return Obx(() {
      final rows = controller.rows.toList(growable: false);
      return _AdminPageFrame(
        title: 'Analytics',
        child: Column(
          children: [
            _DateRangeFilterBar(
              startDate: controller.startDate.value,
              endDate: controller.endDate.value,
              onApply: (startDate, endDate) async {
                controller.startDate.value = startDate;
                controller.endDate.value = endDate;
                await controller.applyFilters();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: TextField(
                controller: controller.search,
                decoration: const InputDecoration(
                  hintText: 'Search employee',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: (_) => controller.applyFilters(),
              ),
            ),
            Expanded(
              child: _PagedBody(
                loading: controller.isLoading.value,
                error: controller.errorText.value,
                isEmpty: rows.isEmpty,
                onRetry: controller.load,
                emptyTitle: 'No analytics',
                emptyMessage: 'Try another date range.',
                child: RefreshIndicator(
                  notificationPredicate: (_) => _showSummary,
                  onRefresh: controller.load,
                  child: Listener(
                    onPointerMove: _handleAnalyticsPointerMove,
                    onPointerUp: (_) => _settleAnalyticsSummaryPull(),
                    onPointerCancel: (_) => _settleAnalyticsSummaryPull(),
                    child: ListView.separated(
                      controller: _analyticsScroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                      itemCount: rows.length + 2,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _AnalyticsSummaryRevealHeader(
                            aggregate: controller.aggregate.value,
                            pullExtent: _summaryPullExtent,
                            threshold: _summaryPullThreshold,
                            isShowing: _showSummary,
                            onHide: () => setState(() {
                              _showSummary = false;
                              _summaryPullExtent = 0;
                            }),
                          );
                        }

                        final rowIndex = index - 1;
                        if (rowIndex == rows.length) {
                          return _Pager(
                            meta: controller.meta.value,
                            onPage: controller.goToPage,
                          );
                        }
                        return _AnalyticsUserCard(row: rows[rowIndex]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _handleAnalyticsPointerMove(PointerMoveEvent event) {
    if (_showSummary || !_analyticsScroll.hasClients) return;

    final position = _analyticsScroll.position;
    final atTop = position.pixels <= position.minScrollExtent + 4;
    if (!atTop || event.delta.dy <= 0) {
      if (_summaryPullExtent != 0) {
        setState(() => _summaryPullExtent = 0);
      }
      return;
    }

    final nextExtent =
        (_summaryPullExtent + event.delta.dy * _summaryPullFactor).clamp(
          0.0,
          _summaryPullThreshold,
        );
    if (nextExtent != _summaryPullExtent) {
      setState(() => _summaryPullExtent = nextExtent);
    }
  }

  void _settleAnalyticsSummaryPull() {
    if (_showSummary || _summaryPullExtent == 0) return;
    setState(() {
      _showSummary =
          _summaryPullExtent / _summaryPullThreshold >= _summarySettleProgress;
      _summaryPullExtent = 0;
    });
  }
}

class AdminLeaveRequestsPage extends StatelessWidget {
  const AdminLeaveRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminLeaveRequestsController>();
    return Obx(
      () => _ApprovalsListPage(
        title: 'Leave Requests',
        rows: controller.rows.toList(growable: false),
        meta: controller.meta.value,
        loading: controller.isLoading.value,
        error: controller.errorText.value,
        search: controller.search,
        status: controller.status.value,
        statuses: controller.statuses,
        onStatus: controller.applyStatus,
        onSearch: controller.submitSearch,
        onRefresh: controller.load,
        onPage: controller.goToPage,
        filters: _LeaveApprovalFilterBar(
          startDate: controller.startDate.value,
          endDate: controller.endDate.value,
          status: controller.status.value,
          statuses: controller.statuses,
          search: controller.search,
          onApply: (startDate, endDate, status) => controller.applyFilters(
            startDate: startDate,
            endDate: endDate,
            status: status,
          ),
          onSearch: controller.submitSearch,
        ),
        itemBuilder: (row) => _AdminApprovalActionCard(
          item: row,
          onThread: () => _openThread(context, controller, row),
          onApprove: () => _approve(context, controller, row),
          onReject: () => _reject(context, controller, row),
        ),
      ),
    );
  }

  Future<void> _openThread(
    BuildContext context,
    AdminLeaveRequestsController controller,
    AdminApprovalItem item,
  ) async {
    if (item.id.isEmpty) return;

    controller.loadThread(item.id, force: true);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _AdminLeaveThreadPage(controller: controller, item: item),
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    AdminLeaveRequestsController controller,
    AdminApprovalItem item,
  ) async {
    final message = await controller.approve(item);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }

  Future<void> _reject(
    BuildContext context,
    AdminLeaveRequestsController controller,
    AdminApprovalItem item,
  ) async {
    final note = await _askText(
      context,
      title: 'Reject Leave',
      label: 'Reason',
    );
    if (note == null) return;
    final message = await controller.reject(item, note);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }
}

class AdminDeviceRequestsPage extends StatelessWidget {
  const AdminDeviceRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminDeviceRequestsController>();
    return Obx(
      () => _ApprovalsListPage(
        title: 'Device Requests',
        rows: controller.rows.toList(growable: false),
        meta: controller.meta.value,
        loading: controller.isLoading.value,
        error: controller.errorText.value,
        search: controller.search,
        status: controller.status.value,
        statuses: controller.statuses,
        onStatus: controller.applyStatus,
        onSearch: controller.submitSearch,
        onRefresh: controller.load,
        onPage: controller.goToPage,
        itemBuilder: (row) => _AdminApprovalActionCard(
          item: row,
          onApprove: () => _approve(context, controller, row),
          onReject: () => _reject(context, controller, row),
        ),
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    AdminDeviceRequestsController controller,
    AdminApprovalItem item,
  ) async {
    final message = await controller.approve(item);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }

  Future<void> _reject(
    BuildContext context,
    AdminDeviceRequestsController controller,
    AdminApprovalItem item,
  ) async {
    final note = await _askText(
      context,
      title: 'Reject Device Change',
      label: 'Reason',
    );
    if (note == null) return;
    final message = await controller.reject(item, note);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }
}

class AdminHolidaysPage extends StatelessWidget {
  const AdminHolidaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminHolidaysController>();
    return Obx(() {
      final rows = controller.rows.toList(growable: false);
      final canManageHolidays = _canManageHolidays();
      return _AdminPageFrame(
        title: 'Holidays',
        trailing: canManageHolidays
            ? IconButton(
                onPressed: () => _openHolidayForm(context, controller),
                icon: const Icon(AppIcons.add, color: AppColors.primaryDark),
              )
            : null,
        child: Column(
          children: [
            _HolidayFilterBar(
              startDate: controller.startDate.value,
              endDate: controller.endDate.value,
              includeDeleted: controller.includeDeleted.value,
              onApply: (startDate, endDate, includeDeleted) async {
                controller.startDate.value = startDate;
                controller.endDate.value = endDate;
                controller.includeDeleted.value = includeDeleted;
                await controller.load();
              },
            ),
            Expanded(
              child: _PagedBody(
                loading: controller.isLoading.value,
                error: controller.errorText.value,
                isEmpty: rows.isEmpty,
                onRetry: controller.load,
                emptyTitle: 'No holidays',
                emptyMessage: 'Create a holiday or change the date range.',
                child: RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                    itemCount: rows.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _HolidayCard(
                        row: rows[index],
                        canManage: canManageHolidays,
                        onEdit: () => _openHolidayForm(
                          context,
                          controller,
                          holiday: rows[index],
                        ),
                        onDelete: () =>
                            _deleteHoliday(context, controller, rows[index]),
                        onHistory: () =>
                            _showHistory(context, controller, rows[index]),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _canManageHolidays() {
    final roles = Get.find<AuthController>().user.value?.roles ?? const [];
    return roles.contains('ADMIN');
  }

  Future<void> _openHolidayForm(
    BuildContext context,
    AdminHolidaysController controller, {
    AdminHoliday? holiday,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _HolidayFormSheet(controller: controller, holiday: holiday),
    );
  }

  Future<void> _deleteHoliday(
    BuildContext context,
    AdminHolidaysController controller,
    AdminHoliday holiday,
  ) async {
    final reason = await _askText(
      context,
      title: 'Delete Holiday',
      label: 'Reason',
    );
    if (reason == null) return;
    final message = await controller.deleteHoliday(holiday, reason);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }

  Future<void> _showHistory(
    BuildContext context,
    AdminHolidaysController controller,
    AdminHoliday holiday,
  ) async {
    try {
      final rows = await controller.history(holiday);
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (context) => _HistorySheet(rows: rows),
      );
    } catch (error) {
      if (!context.mounted) return;
      _showSnack(
        context,
        controller.repository.toReadableError(error),
        isError: true,
      );
    }
  }
}

class AdminWorkFromHomePage extends StatelessWidget {
  const AdminWorkFromHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _adminController<AdminWorkFromHomeController>();
    return Obx(() {
      final rows = controller.rows.toList()..sort();
      return _AdminPageFrame(
        title: 'Work From Home',
        trailing: IconButton(
          onPressed: () => _openAssignSheet(context, controller),
          icon: const Icon(AppIcons.add, color: AppColors.primaryDark),
        ),
        child: Column(
          children: [
            _DateRangeFilterBar(
              startDate: controller.startDate.value,
              endDate: controller.endDate.value,
              onApply: (startDate, endDate) async {
                controller.startDate.value = startDate;
                controller.endDate.value = endDate;
                await controller.applyFilters();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: TextField(
                controller: controller.search,
                decoration: const InputDecoration(
                  hintText: 'Search employee',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: (_) => controller.applyFilters(),
              ),
            ),
            Expanded(
              child: _PagedBody(
                loading: controller.isLoading.value,
                error: controller.errorText.value,
                isEmpty: rows.isEmpty,
                onRetry: controller.load,
                emptyTitle: 'No WFH days',
                emptyMessage: 'Assign work-from-home days from the add button.',
                child: RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                    itemCount: rows.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == rows.length) {
                        return _Pager(
                          meta: controller.meta.value,
                          onPage: controller.goToPage,
                        );
                      }
                      return _WfhCard(
                        row: rows[index],
                        onRemove: (row) => _remove(context, controller, row),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _openAssignSheet(
    BuildContext context,
    AdminWorkFromHomeController controller,
  ) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WfhAssignSheet(controller: controller),
    );
  }

  Future<void> _remove(
    BuildContext context,
    AdminWorkFromHomeController controller,
    AdminWfhRecord record,
  ) async {
    final confirmed = await _confirmWfhRemoval(context, record);
    if (!context.mounted || !confirmed) return;

    final message = await controller.remove(record);
    if (context.mounted && message != null) {
      _showSnack(context, message, isError: true);
    }
  }
}

String _isoDay(Object? value) {
  final text = _text(value);
  if (text.length <= 10) return text;
  return text.substring(0, 10);
}

String _shortDate(Object? value) {
  final text = _isoDay(value);
  if (text.isEmpty) return '-';
  final date = DateTime.tryParse(text);
  if (date == null) return text;
  return DateFormat('MMM d').format(date.toLocal());
}

String _holidayDateRange(Object? startValue, Object? endValue) {
  final startText = _isoDay(startValue);
  final endText = _isoDay(endValue);
  final start = DateTime.tryParse(startText)?.toLocal();
  final end = DateTime.tryParse(endText)?.toLocal();

  if (start == null && end == null) return '-';
  if (start == null) return DateFormat('MMM d, yyyy').format(end!);
  if (end == null || DateUtils.isSameDay(start, end)) {
    return DateFormat('MMM d, yyyy').format(start);
  }
  if (start.year == end.year) {
    return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }
  return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
}

String _time(Object? value) {
  final text = _text(value);
  if (text.isEmpty) return '-';
  final date = DateTime.tryParse(text);
  if (date == null) return text;
  return DateFormat('hh:mm a').format(date.toLocal());
}

String _formatDateTime(Object? value) {
  final text = _text(value);
  if (text.isEmpty) return '';
  final date = DateTime.tryParse(text);
  if (date == null) return text;
  return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}m';
}

String _statusLabel(String value) {
  return switch (value) {
    'halfDay' => 'Half day',
    'onLeave' => 'Leave',
    'weeklyOff' => 'Weekly off',
    'ALL' => 'All',
    _ =>
      value
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' '),
  };
}

String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
}) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

Future<bool> _confirmWfhRemoval(
  BuildContext context,
  AdminWfhRecord record,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Remove WFH Day?'),
        content: Text(
          'Remove work-from-home access for ${record.user.fullName} on ${record.attendanceDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

void _showSnack(BuildContext context, String message, {required bool isError}) {
  AppToast.show(message, isError: isError);
}
