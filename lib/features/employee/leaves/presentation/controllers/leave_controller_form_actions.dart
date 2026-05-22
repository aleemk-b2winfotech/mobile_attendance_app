part of 'leave_controller.dart';

extension LeaveControllerFormActions on LeaveController {
  Future<bool> submit() async {
    submitError.value = null;

    if (!formKey.currentState!.validate()) return false;

    final selectedStart = startDate.value;
    final selectedEnd = isMultiDay.value ? endDate.value : startDate.value;

    if (selectedStart == null || selectedEnd == null) {
      _showInlineSnack(
        message: isMultiDay.value
            ? 'Please choose both start and end dates.'
            : 'Please choose a leave date.',
        isError: true,
      );
      return false;
    }

    if (selectedEnd.isBefore(selectedStart)) {
      _showInlineSnack(
        message: 'End date cannot be before start date.',
        isError: true,
      );
      return false;
    }

    isSubmitting.value = true;

    final reason =
        '[${selectedLeaveType.value}] ${reasonController.text.trim()}';

    try {
      await _repository.createRequest(
        startDate: DateFormat('yyyy-MM-dd').format(selectedStart),
        endDate: DateFormat('yyyy-MM-dd').format(selectedEnd),
        reason: reason,
      );
      isSubmitting.value = false;

      showSuccessBanner.value = true;
      resetForm();
      await loadRequests(page: 1);
      _showInlineSnack(
        message: 'Leave request submitted successfully.',
        isError: false,
      );
      return true;
    } catch (error) {
      submitError.value = _repository.toReadableError(error);
      isSubmitting.value = false;
      _showInlineSnack(
        message: submitError.value ?? 'Unable to submit leave request.',
        isError: true,
      );
      return false;
    }
  }

  void clearSubmitError() {
    submitError.value = null;
  }

  void setMultiDay(bool value) {
    if (isMultiDay.value == value) return;
    isMultiDay.value = value;

    if (!value) {
      endDate.value = startDate.value;
      return;
    }

    if (startDate.value != null && endDate.value == null) {
      endDate.value = startDate.value;
    }
  }

  Future<void> pickDate({required bool isStart}) async {
    final now = _dateOnly(DateTime.now());
    final firstDate = isStart ? now : (startDate.value ?? now);

    final seedDate = _dateOnly(
      isStart
          ? (startDate.value ?? now)
          : (endDate.value ?? startDate.value ?? now),
    );

    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: seedDate.isBefore(firstDate) ? firstDate : seedDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) return;

    final normalized = _dateOnly(picked);

    if (isStart) {
      startDate.value = normalized;
      if (!isMultiDay.value) {
        endDate.value = normalized;
        return;
      }

      if (endDate.value == null || endDate.value!.isBefore(normalized)) {
        endDate.value = normalized;
      }
      return;
    }

    endDate.value = normalized;
  }

  void resetForm() {
    submitError.value = null;
    selectedLeaveType.value = LeaveController.leaveTypes.first;
    isMultiDay.value = false;
    startDate.value = null;
    endDate.value = null;
    reasonController.clear();
  }
}
