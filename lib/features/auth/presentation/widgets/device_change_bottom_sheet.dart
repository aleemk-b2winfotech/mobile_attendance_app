import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';

Future<void> showDeviceChangeBottomSheet(BuildContext context) {
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<void>(
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
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        AppIcons.mobile,
                        color: AppColors.warningDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Mismatch',
                            style: Theme.of(sheetContext).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This device is not registered to your account.',
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Why do you need to switch to this device?',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Reason is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final auth = Get.find<AuthController>();

                    return FilledButton(
                      onPressed: auth.isLoading.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              final success = await auth.requestDeviceChange(
                                reasonController.text.trim(),
                              );

                              if (!sheetContext.mounted || !context.mounted) {
                                return;
                              }

                              Navigator.of(sheetContext).pop();

                              AppToast.show(
                                success
                                    ? 'Device change request submitted. Please wait for admin approval.'
                                    : auth.errorText.value ??
                                          'Failed to submit request.',
                                isError: !success,
                              );
                            },
                      child: auth.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit Request'),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
