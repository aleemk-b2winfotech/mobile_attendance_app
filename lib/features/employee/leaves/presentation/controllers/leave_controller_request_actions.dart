part of 'leave_controller.dart';

extension LeaveControllerRequestActions on LeaveController {
  Future<void> loadRequests({
    Object? status = _keepExistingStatus,
    int? page,
  }) async {
    final resolvedStatus = identical(status, _keepExistingStatus)
        ? statusFilter.value
        : status as String?;
    final targetPage = page ?? currentPage.value;

    isLoading.value = true;
    errorText.value = null;
    statusFilter.value = resolvedStatus;
    currentPage.value = targetPage;

    try {
      final result = await _fetchPage(status: resolvedStatus, page: targetPage);
      requests.assignAll(result.requests);
      currentPage.value = result.currentPage;
      totalPages.value = result.totalPages;
      totalRequests.value = result.totalRequests;
      pageSize.value = result.pageSize;
    } catch (error) {
      errorText.value = _repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<LeaveRequestPage> _fetchPage({
    required String? status,
    required int page,
  }) async {
    final result = await _repository.fetchRequests(
      status: status,
      page: page,
      limit: pageSize.value,
    );

    if (result.totalRequests > 0 && result.currentPage > result.totalPages) {
      return _fetchPage(status: status, page: result.totalPages);
    }

    return result;
  }

  Future<String?> cancelRequest(String id) async {
    if (cancellingIds.contains(id)) return null;

    cancellingIds.add(id);
    try {
      await _repository.cancelRequest(id);
      await loadRequests(page: currentPage.value);
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    } finally {
      cancellingIds.remove(id);
    }
  }

  bool isCancelling(String id) => cancellingIds.contains(id);

  Future<void> applyStatusFilter(String? status) async {
    await loadRequests(status: status, page: 1);
  }

  Future<void> loadNextPage() async {
    if (!hasNextPage) return;
    await loadRequests(page: currentPage.value + 1);
  }

  Future<void> loadPreviousPage() async {
    if (!hasPreviousPage) return;
    await loadRequests(page: currentPage.value - 1);
  }

  bool get hasPreviousPage => currentPage.value > 1;

  bool get hasNextPage => currentPage.value < totalPageCount;

  int get totalPageCount => math.max(1, totalPages.value);

  int get firstVisibleIndex {
    if (totalRequests.value == 0) return 0;
    return ((currentPage.value - 1) * pageSize.value) + 1;
  }

  int get lastVisibleIndex {
    if (totalRequests.value == 0) return 0;
    return math.min(
      firstVisibleIndex + requests.length - 1,
      totalRequests.value,
    );
  }
}
