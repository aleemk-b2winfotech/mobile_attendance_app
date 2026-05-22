import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:app/features/administration/approvals/data/admin_approval_repository.dart';
import 'package:app/features/administration/approvals/domain/models/admin_approval_models.dart';
import 'package:app/features/administration/dashboard/data/admin_dashboard_repository.dart';
import 'package:app/features/administration/dashboard/domain/models/admin_dashboard_models.dart';
import 'package:app/features/administration/team/data/admin_user_repository.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

enum AdminApprovalTab { leave, device }

class AdminDashboardController extends GetxController {
  AdminDashboardController(
    this._dashboardRepository,
    this._userRepository,
    this._approvalRepository,
  );

  final AdminDashboardRepository _dashboardRepository;
  final AdminUserRepository _userRepository;
  final AdminApprovalRepository _approvalRepository;

  final Rxn<AdminDashboardSnapshot> dashboard = Rxn<AdminDashboardSnapshot>();
  final RxList<AdminUser> users = <AdminUser>[].obs;
  final RxList<AdminApprovalItem> approvals = <AdminApprovalItem>[].obs;
  final Rx<AdminApprovalTab> activeApprovalTab = AdminApprovalTab.leave.obs;
  final RxString leaveApprovalStatus = 'PENDING'.obs;
  final RxString deviceApprovalStatus = 'PENDING'.obs;
  final RxString leaveApprovalStartDate = _monthStart().obs;
  final RxString leaveApprovalEndDate = _today().obs;
  final RxString leaveApprovalSearch = ''.obs;
  final RxString deviceApprovalSearch = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isApprovalsLoading = false.obs;
  final RxSet<String> actionIds = <String>{}.obs;
  final RxMap<String, LeaveThread> threads = <String, LeaveThread>{}.obs;
  final RxSet<String> threadLoadingIds = <String>{}.obs;
  final RxSet<String> threadSubmittingIds = <String>{}.obs;
  final RxSet<String> acceptingProposalIds = <String>{}.obs;
  final RxnString errorText = RxnString();
  final TextEditingController leaveApprovalSearchController =
      TextEditingController();
  final TextEditingController deviceApprovalSearchController =
      TextEditingController();

  List<AdminApprovalItem> get leaveApprovals => approvals
      .where((item) => item.kind == AdminApprovalKind.leave)
      .toList(growable: false);

  List<AdminApprovalItem> get deviceApprovals => approvals
      .where((item) => item.kind == AdminApprovalKind.deviceChange)
      .toList(growable: false);

  List<String> approvalStatusesFor(AdminApprovalTab tab) {
    return switch (tab) {
      AdminApprovalTab.leave => const [
        'ALL',
        'PENDING',
        'APPROVED',
        'REJECTED',
        'CANCELLED',
      ],
      AdminApprovalTab.device => const [
        'ALL',
        'PENDING',
        'APPROVED',
        'REJECTED',
      ],
    };
  }

  String get activeApprovalStatus {
    return switch (activeApprovalTab.value) {
      AdminApprovalTab.leave => leaveApprovalStatus.value,
      AdminApprovalTab.device => deviceApprovalStatus.value,
    };
  }

  String get activeApprovalSearch {
    return switch (activeApprovalTab.value) {
      AdminApprovalTab.leave => leaveApprovalSearch.value,
      AdminApprovalTab.device => deviceApprovalSearch.value,
    };
  }

  void setActiveApprovalTab(AdminApprovalTab tab) {
    if (activeApprovalTab.value == tab) return;
    activeApprovalTab.value = tab;
  }

  Future<void> applyActiveApprovalStatus(String status) async {
    final target = activeApprovalTab.value == AdminApprovalTab.leave
        ? leaveApprovalStatus
        : deviceApprovalStatus;
    if (target.value == status) return;
    target.value = status;
    await refreshData();
  }

  @override
  void onInit() {
    super.onInit();
    leaveApprovalSearchController.text = leaveApprovalSearch.value;
    deviceApprovalSearchController.text = deviceApprovalSearch.value;
    refreshData();
  }

  @override
  void onClose() {
    leaveApprovalSearchController.dispose();
    deviceApprovalSearchController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    isApprovalsLoading.value = true;
    errorText.value = null;

    final now = DateTime.now();
    final startDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month));
    final endDate = DateFormat('yyyy-MM-dd').format(now);
    final leaveStatus = leaveApprovalStatus.value;
    final deviceStatus = deviceApprovalStatus.value;

    try {
      final dashboardRequest = _dashboardRepository.fetchSnapshot(
        startDate: startDate,
        endDate: endDate,
      );
      final usersRequest = _userRepository.fetchUsers(limit: 50);

      dashboard.value = await dashboardRequest;
      users.assignAll(await usersRequest);
      await _refreshApprovalsData(
        leaveStatus: leaveStatus,
        deviceStatus: deviceStatus,
      );
    } catch (error) {
      errorText.value = _dashboardRepository.toReadableError(error);
    } finally {
      isLoading.value = false;
      isApprovalsLoading.value = false;
    }
  }

  Future<void> applyLeaveApprovalFilters({
    required String status,
    required String startDate,
    required String endDate,
    String? search,
  }) async {
    leaveApprovalStatus.value = status;
    leaveApprovalStartDate.value = startDate;
    leaveApprovalEndDate.value = endDate;
    if (search != null) {
      leaveApprovalSearch.value = search.trim();
      if (leaveApprovalSearchController.text != leaveApprovalSearch.value) {
        leaveApprovalSearchController.text = leaveApprovalSearch.value;
      }
    }
    await refreshApprovals();
  }

  Future<void> applyDeviceApprovalFilters({
    required String status,
    String? search,
  }) async {
    deviceApprovalStatus.value = status;
    if (search != null) {
      deviceApprovalSearch.value = search.trim();
      if (deviceApprovalSearchController.text != deviceApprovalSearch.value) {
        deviceApprovalSearchController.text = deviceApprovalSearch.value;
      }
    }
    await refreshApprovals();
  }

  Future<void> refreshApprovals({bool refreshDashboard = false}) async {
    isApprovalsLoading.value = true;
    errorText.value = null;

    try {
      if (refreshDashboard) {
        final now = DateTime.now();
        final startDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(now.year, now.month));
        final endDate = DateFormat('yyyy-MM-dd').format(now);
        dashboard.value = await _dashboardRepository.fetchSnapshot(
          startDate: startDate,
          endDate: endDate,
        );
      }

      await _refreshApprovalsData(
        leaveStatus: leaveApprovalStatus.value,
        deviceStatus: deviceApprovalStatus.value,
      );
    } catch (error) {
      errorText.value = _dashboardRepository.toReadableError(error);
    } finally {
      isApprovalsLoading.value = false;
    }
  }

  Future<void> _refreshApprovalsData({
    required String leaveStatus,
    required String deviceStatus,
  }) async {
    final leaveRequests = _approvalRepository.fetchLeaveApprovalItems(
      status: leaveStatus == 'ALL' ? null : leaveStatus,
      startDate: leaveApprovalStartDate.value,
      endDate: leaveApprovalEndDate.value,
      search: leaveApprovalSearch.value,
      limit: 20,
    );
    final deviceRequests = _approvalRepository.fetchDeviceChangeApprovalItems(
      status: deviceStatus == 'ALL' ? null : deviceStatus,
      search: deviceApprovalSearch.value,
      limit: 20,
    );

    final leaveItems = await leaveRequests;
    final deviceItems = await deviceRequests;
    approvals.assignAll(<AdminApprovalItem>[...leaveItems, ...deviceItems]);
  }

  Future<String?> approve(AdminApprovalItem item) async {
    if (actionIds.contains(item.id)) return null;

    actionIds.add(item.id);
    try {
      switch (item.kind) {
        case AdminApprovalKind.leave:
          await _approvalRepository.approveLeaveRequest(item.id);
        case AdminApprovalKind.deviceChange:
          await _approvalRepository.approveDeviceChangeRequest(item.id);
      }
      await refreshApprovals(refreshDashboard: true);
      return null;
    } catch (error) {
      return _approvalRepository.toReadableError(error);
    } finally {
      actionIds.remove(item.id);
    }
  }

  Future<String?> reject(AdminApprovalItem item, String note) async {
    if (actionIds.contains(item.id)) return null;

    actionIds.add(item.id);
    try {
      switch (item.kind) {
        case AdminApprovalKind.leave:
          await _approvalRepository.rejectLeaveRequest(item.id, note);
        case AdminApprovalKind.deviceChange:
          await _approvalRepository.rejectDeviceChangeRequest(item.id, note);
      }
      await refreshApprovals(refreshDashboard: true);
      return null;
    } catch (error) {
      return _approvalRepository.toReadableError(error);
    } finally {
      actionIds.remove(item.id);
    }
  }

  LeaveThread? threadFor(String id) => threads[id];

  bool isThreadLoading(String id) => threadLoadingIds.contains(id);

  bool isThreadSubmitting(String id) => threadSubmittingIds.contains(id);

  bool isAcceptingProposal(String id) => acceptingProposalIds.contains(id);

  Future<LeaveThread?> loadThread(String id, {bool force = false}) async {
    if (!force && threads.containsKey(id)) return threads[id];
    if (threadLoadingIds.contains(id)) return threads[id];

    threadLoadingIds.add(id);
    try {
      final response = await _approvalRepository.fetchLeaveRequestThread(id);
      final thread = LeaveThread.fromJson(response);
      threads[id] = thread;
      return thread;
    } catch (error) {
      errorText.value = _approvalRepository.toReadableError(error);
      return null;
    } finally {
      threadLoadingIds.remove(id);
    }
  }

  Future<String?> createThreadMessage({
    required String leaveRequestId,
    required String message,
    String? proposedStartDate,
    String? proposedEndDate,
  }) async {
    if (threadSubmittingIds.contains(leaveRequestId)) return null;

    threadSubmittingIds.add(leaveRequestId);
    try {
      await _approvalRepository.createLeaveThreadMessage(
        leaveRequestId: leaveRequestId,
        message: message,
        proposedStartDate: proposedStartDate,
        proposedEndDate: proposedEndDate,
      );
      await loadThread(leaveRequestId, force: true);
      return null;
    } catch (error) {
      return _approvalRepository.toReadableError(error);
    } finally {
      threadSubmittingIds.remove(leaveRequestId);
    }
  }

  Future<String?> acceptThreadProposal({
    required String leaveRequestId,
    required String messageId,
  }) async {
    if (acceptingProposalIds.contains(messageId)) return null;

    acceptingProposalIds.add(messageId);
    try {
      await _approvalRepository.acceptLeaveThreadProposal(
        leaveRequestId: leaveRequestId,
        messageId: messageId,
      );
      await loadThread(leaveRequestId, force: true);
      await refreshApprovals(refreshDashboard: true);
      return null;
    } catch (error) {
      return _approvalRepository.toReadableError(error);
    } finally {
      acceptingProposalIds.remove(messageId);
    }
  }
}

String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

String _monthStart() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month));
}
