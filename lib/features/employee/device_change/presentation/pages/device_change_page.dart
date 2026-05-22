import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/core/widgets/button_spinner.dart';
import 'package:app/features/employee/device_change/presentation/controllers/device_change_controller.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

part 'widgets/device_change_page_widgets.dart';

class DeviceChangePage extends GetView<DeviceChangeController> {
  const DeviceChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Change Requests')),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorText.value != null && controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.warning, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(controller.errorText.value!),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: controller.loadRequests,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRequests,
          child: controller.requests.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.mobile,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No device change requests',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: controller.requests.length,
                  itemBuilder: (context, index) {
                    return _RequestCard(request: controller.requests[index]);
                  },
                ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, controller),
        backgroundColor: AppColors.primaryDark,
        child: const Icon(AppIcons.add, color: Colors.white, size: 22),
      ),
    );
  }

  void _showCreateSheet(
    BuildContext context,
    DeviceChangeController controller,
  ) {
    controller.prepareCreateRequest();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Form(
              key: controller.createFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Device Change',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your current device will be replaced after approval.',
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        sheetContext,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Why do you need to change your device?',
                    ),
                    validator: controller.validateReason,
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final success = await controller
                                    .submitCreateRequest();

                                if (!sheetContext.mounted || !context.mounted) {
                                  return;
                                }

                                if (success) {
                                  Navigator.of(sheetContext).pop();
                                  if (!context.mounted) return;
                                  AppToast.success(
                                    'Device change request submitted',
                                  );
                                  return;
                                }

                                AppToast.error(
                                  controller.submitError.value ??
                                      'Failed to submit request.',
                                );
                              },
                        child: controller.isSubmitting.value
                            ? const ButtonSpinner()
                            : const Text('Submit Request'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
