part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _ApprovalTile extends GetView<AdminDashboardController> {
  const _ApprovalTile({required this.item});

  final AdminApprovalItem item;

  @override
  Widget build(BuildContext context) {
    final isLeave = item.kind == AdminApprovalKind.leave;
    final pending = item.status == 'PENDING';

    if (isLeave) {
      return _buildLeaveCard(context);
    }

    return _buildDeviceCard(context, pending: pending);
  }

  Widget _buildLeaveCard(BuildContext context) {
    final status = item.status;
    final statusColor = _approvalStatusColor(status);
    final statusSurface = _approvalStatusSoftColor(status);
    final dateLabel = _homeLeaveApprovalDate(item);
    final leaveType = inferLeaveType(item.detail);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(borderColor: const Color(0x0D1D3C8B)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _approvalStatusIcon(status),
                  size: 17,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(
                label: _approvalStatusLabel(status),
                status: status,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x0D1D3C8B))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AdminHomeApprovalMetricBlock(
                    label: 'LEAVE TYPE',
                    value: leaveType,
                    valueColor: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _openThread(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(AppIcons.chat, size: 15),
                  label: const Text('View'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, {required bool pending}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AppIcons.mobile,
                color: AppColors.warningDark,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.employeeName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              StatusChip(
                label: _approvalStatusLabel(item.status),
                status: item.status,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.title, style: Theme.of(context).textTheme.bodyMedium),
          if (item.detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.detail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (pending) ...[
            const SizedBox(height: 12),
            Obx(() {
              final busy = controller.actionIds.contains(item.id);
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => _reject(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: busy ? null : () => _approve(context),
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Approve'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _openThread(BuildContext context) async {
    controller.loadThread(item.id, force: true);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdminHomeLeaveThreadPage(item: item),
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final message = await controller.approve(item);
    if (!context.mounted || message == null) return;
    AppToast.error(message);
  }

  Future<void> _reject(BuildContext context) async {
    final note = await _askForRejectionNote(context);
    if (!context.mounted || note == null) return;

    final message = await controller.reject(item, note);
    if (!context.mounted || message == null) return;
    AppToast.error(message);
  }

  Future<String?> _askForRejectionNote(BuildContext context) async {
    return _askForAdminHomeRejectionNote(context);
  }
}

class _AdminHomeApprovalMetricBlock extends StatelessWidget {
  const _AdminHomeApprovalMetricBlock({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

Future<String?> _askForAdminHomeRejectionNote(BuildContext context) async {
  final textController = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: textController,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(textController.text),
            child: const Text('Reject'),
          ),
        ],
      );
    },
  );
  textController.dispose();
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
