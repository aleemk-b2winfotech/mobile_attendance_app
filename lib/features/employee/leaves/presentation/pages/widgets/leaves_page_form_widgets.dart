part of '../leaves_page.dart';

class _LeaveForm extends GetView<LeaveController> {
  const _LeaveForm({this.onSubmitted});

  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedStart = controller.startDate.value;
      final selectedEnd = controller.isMultiDay.value
          ? controller.endDate.value
          : controller.startDate.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(
          radius: BorderRadius.circular(18),
          borderColor: const Color(0x0D1D3C8B),
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('Leave Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedLeaveType.value,
                borderRadius: BorderRadius.circular(10),
                icon: const Icon(
                  AppIcons.arrowDown,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                items: LeaveController.leaveTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  controller.selectedLeaveType.value = value;
                },
              ),
              const SizedBox(height: 16),
              _DateFields(
                isMultiDay: controller.isMultiDay.value,
                startDate: selectedStart,
                endDate: selectedEnd,
                onToggleMultiDay: controller.setMultiDay,
                onPickStart: () => controller.pickDate(isStart: true),
                onPickEnd: () => controller.pickDate(isStart: false),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Reason'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Explain the reason for leave...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reason is required.';
                  }
                  return null;
                },
              ),
              if (controller.submitError.value != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.warning,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.submitError.value!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        final ok = await controller.submit();
                        if (ok) onSubmitted?.call();
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Submit Request'),
                          SizedBox(width: 8),
                          Icon(
                            AppIcons.arrowForward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DateFields extends StatelessWidget {
  const _DateFields({
    required this.isMultiDay,
    required this.startDate,
    required this.endDate,
    required this.onToggleMultiDay,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final bool isMultiDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<bool> onToggleMultiDay;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionLabel('Dates')),
            Text(
              'Multi-day',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                value: isMultiDay,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryDark,
                onChanged: onToggleMultiDay,
              ),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isMultiDay
              ? Row(
                  key: const ValueKey('range'),
                  children: [
                    Expanded(
                      child: _DateInput(
                        label: 'From',
                        date: startDate,
                        placeholder: 'Select start',
                        onTap: onPickStart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateInput(
                        label: 'To',
                        date: endDate,
                        placeholder: 'Select end',
                        onTap: onPickEnd,
                      ),
                    ),
                  ],
                )
              : _DateInput(
                  key: const ValueKey('single'),
                  label: 'Leave Date',
                  date: startDate,
                  placeholder: 'Select date',
                  onTap: onPickStart,
                ),
        ),
      ],
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    super.key,
    required this.label,
    required this.date,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDate
                ? AppColors.primaryDark.withValues(alpha: 0.18)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasDate ? AppIcons.calendarTick : AppIcons.calendarOutline,
              size: 18,
              color: hasDate ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasDate
                        ? DateFormat('dd MMM yyyy').format(date!)
                        : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              AppIcons.arrowForward,
              size: 12,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
