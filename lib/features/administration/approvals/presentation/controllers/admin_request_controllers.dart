import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/features/administration/approvals/data/admin_approval_repository.dart';
import 'package:app/features/administration/approvals/domain/models/admin_approval_models.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management/admin_management_base_controller.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

abstract class AdminRequestsController
    extends
        AdminPagedDataController<AdminApprovalRepository, AdminApprovalItem> {
  AdminRequestsController(super.repository);

  final TextEditingController search = TextEditingController();
  final RxString status = 'PENDING'.obs;

  List<String> get statuses;

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

  Future<void> applyStatus(String value) async {
    status.value = value;
    page.value = 1;
    await load();
  }

  Future<void> submitSearch() async {
    page.value = 1;
    await load();
  }

  Future<String?> approve(AdminApprovalItem item);

  Future<String?> reject(AdminApprovalItem item, String note);
}

class AdminLeaveRequestsController extends AdminRequestsController {
  AdminLeaveRequestsController(super.repository);

  final RxString startDate = adminMonthStart().obs;
  final RxString endDate = adminMonthEnd().obs;
  final RxMap<String, LeaveThread> threads = <String, LeaveThread>{}.obs;
  final RxSet<String> threadLoadingIds = <String>{}.obs;
  final RxSet<String> threadSubmittingIds = <String>{}.obs;
  final RxSet<String> acceptingProposalIds = <String>{}.obs;

  @override
  List<String> get statuses => const [
    'ALL',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'CANCELLED',
  ];

  @override
  Future<void> load() {
    return runPagedLoad(
      () => repository.fetchLeaveApprovalPage(
        status: status.value == 'ALL' ? null : status.value,
        startDate: startDate.value,
        endDate: endDate.value,
        search: search.text,
        page: page.value,
        limit: 20,
      ),
    );
  }

  Future<void> applyFilters({
    required String startDate,
    required String endDate,
    required String status,
  }) async {
    this.startDate.value = startDate;
    this.endDate.value = endDate;
    this.status.value = status;
    page.value = 1;
    await load();
  }

  @override
  Future<String?> approve(AdminApprovalItem item) async {
    if (item.id.isEmpty) return null;
    return _runAction(() => repository.approveLeaveRequest(item.id));
  }

  @override
  Future<String?> reject(AdminApprovalItem item, String note) async {
    if (item.id.isEmpty) return null;
    return _runAction(() => repository.rejectLeaveRequest(item.id, note));
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
      final response = await repository.fetchLeaveRequestThread(id);
      final thread = LeaveThread.fromJson(response);
      threads[id] = thread;
      return thread;
    } catch (error) {
      errorText.value = repository.toReadableError(error);
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
      await repository.createLeaveThreadMessage(
        leaveRequestId: leaveRequestId,
        message: message,
        proposedStartDate: proposedStartDate,
        proposedEndDate: proposedEndDate,
      );
      await loadThread(leaveRequestId, force: true);
      return null;
    } catch (error) {
      return repository.toReadableError(error);
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
      await repository.acceptLeaveThreadProposal(
        leaveRequestId: leaveRequestId,
        messageId: messageId,
      );
      await loadThread(leaveRequestId, force: true);
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    } finally {
      acceptingProposalIds.remove(messageId);
    }
  }

  Future<String?> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }
}

class AdminDeviceRequestsController extends AdminRequestsController {
  AdminDeviceRequestsController(super.repository);

  @override
  List<String> get statuses => const ['ALL', 'PENDING', 'APPROVED', 'REJECTED'];

  @override
  Future<void> load() {
    return runPagedLoad(
      () => repository.fetchDeviceChangeApprovalPage(
        status: status.value == 'ALL' ? null : status.value,
        search: search.text,
        page: page.value,
        limit: 20,
      ),
    );
  }

  @override
  Future<String?> approve(AdminApprovalItem item) async {
    if (item.id.isEmpty) return null;
    return _runAction(() => repository.approveDeviceChangeRequest(item.id));
  }

  @override
  Future<String?> reject(AdminApprovalItem item, String note) async {
    if (item.id.isEmpty) return null;
    return _runAction(
      () => repository.rejectDeviceChangeRequest(item.id, note),
    );
  }

  Future<String?> _runAction(Future<void> Function() action) async {
    try {
      await action();
      await load();
      return null;
    } catch (error) {
      return repository.toReadableError(error);
    }
  }
}
