import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/features/employee/device_change/data/device_change_repository.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

class DeviceChangeController extends GetxController {
  DeviceChangeController(this._repository, this._authController);

  final DeviceChangeRepository _repository;
  final AuthController _authController;

  final RxList<DeviceChangeRequest> requests = <DeviceChangeRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString errorText = RxnString();
  final RxnString submitError = RxnString();
  final GlobalKey<FormState> createFormKey = GlobalKey<FormState>();
  late final TextEditingController reasonController;

  @override
  void onInit() {
    super.onInit();
    reasonController = TextEditingController();
    loadRequests();
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }

  Future<void> loadRequests() async {
    isLoading.value = true;
    errorText.value = null;

    try {
      requests.assignAll(await _repository.fetchRequests());
    } catch (error) {
      errorText.value = _repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitRequest({
    required String requestedDeviceId,
    required String reason,
  }) async {
    submitError.value = null;
    isSubmitting.value = true;

    try {
      await _repository.submitRequest(
        requestedDeviceId: requestedDeviceId,
        reason: reason,
      );
      return true;
    } catch (error) {
      submitError.value = _repository.toReadableError(error);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearSubmitError() {
    submitError.value = null;
  }

  void prepareCreateRequest() {
    reasonController.clear();
    clearSubmitError();
  }

  String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reason is required';
    }
    return null;
  }

  Future<bool> submitCreateRequest() async {
    final formState = createFormKey.currentState;
    if (formState == null || !formState.validate()) return false;

    final success = await submitRequest(
      requestedDeviceId: _authController.deviceId ?? 'unknown_device',
      reason: reasonController.text.trim(),
    );

    if (success) {
      reasonController.clear();
      await loadRequests();
    }

    return success;
  }
}
