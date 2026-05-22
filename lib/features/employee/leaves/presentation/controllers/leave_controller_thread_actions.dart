part of 'leave_controller.dart';

extension LeaveControllerThreadActions on LeaveController {
  LeaveThread? threadFor(String id) => threads[id];

  bool isThreadLoading(String id) => threadLoadingIds.contains(id);

  bool isThreadSubmitting(String id) => threadSubmittingIds.contains(id);

  bool isAcceptingProposal(String id) => acceptingProposalIds.contains(id);

  Future<LeaveThread?> loadThread(String id, {bool force = false}) async {
    if (!force && threads.containsKey(id)) return threads[id];
    if (threadLoadingIds.contains(id)) return threads[id];

    threadLoadingIds.add(id);
    try {
      final thread = await _repository.fetchRequestThread(id);
      threads[id] = thread;
      return thread;
    } catch (error) {
      _showInlineSnack(
        message: _repository.toReadableError(error),
        isError: true,
      );
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
      await _repository.createThreadMessage(
        leaveRequestId: leaveRequestId,
        message: message,
        proposedStartDate: proposedStartDate,
        proposedEndDate: proposedEndDate,
      );
      await loadThread(leaveRequestId, force: true);
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
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
      await _repository.acceptThreadProposal(
        leaveRequestId: leaveRequestId,
        messageId: messageId,
      );
      await loadThread(leaveRequestId, force: true);
      await loadRequests(page: currentPage.value);
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    } finally {
      acceptingProposalIds.remove(messageId);
    }
  }
}
