part of '../leaves_page.dart';

class _LeaveThreadSheet extends StatefulWidget {
  const _LeaveThreadSheet({required this.request});

  final LeaveRequest request;

  @override
  State<_LeaveThreadSheet> createState() => _LeaveThreadSheetState();
}

class _LeaveThreadSheetState extends State<_LeaveThreadSheet> {
  final TextEditingController _messageController = TextEditingController();
  bool _isProposal = false;
  DateTime? _proposedStartDate;
  DateTime? _proposedEndDate;

  LeaveController get _controller => Get.find<LeaveController>();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.request.status.toUpperCase() == 'PENDING';

    return SheetPadding(
      child: Obx(() {
        final thread = _controller.threadFor(widget.request.id);
        final loading = _controller.isThreadLoading(widget.request.id);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(AppIcons.chat, color: AppColors.primaryDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Leave Thread',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                StatusChip(
                  label: sentenceCaseStatus(widget.request.status),
                  status: widget.request.status,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _requestRangeSummary(widget.request),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            if (loading && thread == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (thread == null || thread.messages.isEmpty)
              const EmptyInfoCard(
                title: 'No thread yet',
                message: 'Messages for this leave request will appear here.',
                icon: AppIcons.chat,
              )
            else
              ...thread.messages.map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LeaveThreadMessageTile(
                    request: widget.request,
                    message: message,
                    onAccept: pending && _canEmployeeAccept(message)
                        ? () => _acceptProposal(context, message)
                        : null,
                  ),
                ),
              ),
            if (loading && thread != null) ...[
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  color: AppColors.primaryDark,
                  backgroundColor: AppColors.border,
                ),
              ),
            ],
            if (pending) ...[
              const SizedBox(height: 10),
              _buildComposer(context),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final submitting = _controller.isThreadSubmitting(widget.request.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reply',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Propose dates',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: _isProposal,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primaryDark,
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            _isProposal = value;
                            if (!value) {
                              _proposedStartDate = null;
                              _proposedEndDate = null;
                            }
                          });
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            minLines: 2,
            maxLines: 4,
            enabled: !submitting,
            decoration: InputDecoration(
              hintText: _isProposal
                  ? 'Add context for the proposed dates...'
                  : 'Write a comment...',
            ),
          ),
          if (_isProposal) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateInput(
                    label: 'From',
                    date: _proposedStartDate,
                    placeholder: 'Start',
                    onTap: submitting
                        ? () {}
                        : () => _pickProposalDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateInput(
                    label: 'To',
                    date: _proposedEndDate,
                    placeholder: 'End',
                    onTap: submitting
                        ? () {}
                        : () => _pickProposalDate(isStart: false),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submitting ? null : () => _sendMessage(context),
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(AppIcons.send, size: 16),
              label: Text(_isProposal ? 'Send Proposal' : 'Send Comment'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canEmployeeAccept(LeaveThreadMessage message) {
    return message.isProposal && message.actorUserId != widget.request.userId;
  }

  Future<void> _sendMessage(BuildContext context) async {
    final message = _messageController.text.trim();

    if (_isProposal &&
        (_proposedStartDate == null || _proposedEndDate == null)) {
      _showSheetSnack(context, 'Choose both proposed dates.', isError: true);
      return;
    }

    if (!_isProposal && message.isEmpty) {
      _showSheetSnack(context, 'Write a comment first.', isError: true);
      return;
    }

    if (_isProposal && _proposedEndDate!.isBefore(_proposedStartDate!)) {
      _showSheetSnack(
        context,
        'Proposed end date cannot be before the start date.',
        isError: true,
      );
      return;
    }

    final error = await _controller.createThreadMessage(
      leaveRequestId: widget.request.id,
      message: message,
      proposedStartDate: _isProposal
          ? DateFormat('yyyy-MM-dd').format(_proposedStartDate!)
          : null,
      proposedEndDate: _isProposal
          ? DateFormat('yyyy-MM-dd').format(_proposedEndDate!)
          : null,
    );

    if (!context.mounted) return;
    if (error != null) {
      _showSheetSnack(context, error, isError: true);
      return;
    }

    _messageController.clear();
    setState(() {
      _isProposal = false;
      _proposedStartDate = null;
      _proposedEndDate = null;
    });
  }

  Future<void> _acceptProposal(
    BuildContext context,
    LeaveThreadMessage message,
  ) async {
    final error = await _controller.acceptThreadProposal(
      leaveRequestId: widget.request.id,
      messageId: message.id,
    );

    if (!context.mounted) return;
    if (error != null) {
      _showSheetSnack(context, error, isError: true);
      return;
    }

    _showSheetSnack(context, 'Proposal accepted.', isError: false);
    Navigator.of(context).maybePop();
  }

  Future<void> _pickProposalDate({required bool isStart}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = isStart ? today : (_proposedStartDate ?? today);
    final seed = isStart
        ? (_proposedStartDate ?? today)
        : (_proposedEndDate ?? _proposedStartDate ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: seed.isBefore(firstDate) ? firstDate : seed,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 1),
    );
    if (picked == null) return;

    final normalized = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      if (isStart) {
        _proposedStartDate = normalized;
        if (_proposedEndDate == null ||
            _proposedEndDate!.isBefore(normalized)) {
          _proposedEndDate = normalized;
        }
        return;
      }
      _proposedEndDate = normalized;
    });
  }

  String _requestRangeSummary(LeaveRequest request) {
    final range = request.effectiveStartDate == request.effectiveEndDate
        ? formatDate(request.effectiveStartDate, pattern: 'd MMM yyyy')
        : '${formatDate(request.effectiveStartDate, pattern: 'd MMM')} - '
              '${formatDate(request.effectiveEndDate, pattern: 'd MMM yyyy')}';
    final days = request.effectiveWorkingDayCount;
    if (days <= 0) return range;
    return '$range • $days working ${days == 1 ? 'day' : 'days'}';
  }

  void _showSheetSnack(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    AppToast.show(message, isError: isError);
  }
}

class _LeaveThreadMessageTile extends StatelessWidget {
  const _LeaveThreadMessageTile({
    required this.request,
    required this.message,
    this.onAccept,
  });

  final LeaveRequest request;
  final LeaveThreadMessage message;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final typeLabel = _messageTypeLabel(message.messageType);
    final note = message.message?.trim() ?? '';
    final actor = message.actor?.fullName.trim();
    final actorLabel = actor == null || actor.isEmpty ? 'User' : actor;
    final isAccepting = Get.find<LeaveController>().isAcceptingProposal(
      message.id,
    );

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _messageTypeColor(
                    message.messageType,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _messageTypeIcon(message.messageType),
                  size: 17,
                  color: _messageTypeColor(message.messageType),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$actorLabel • ${formatRelative(message.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(note, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (message.hasProposedDates) ...[
            const SizedBox(height: 10),
            _ThreadDateProposal(message: message),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAccepting ? null : onAccept,
                icon: isAccepting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(AppIcons.check, size: 16),
                label: const Text('Accept Proposal'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThreadDateProposal extends StatelessWidget {
  const _ThreadDateProposal({required this.message});

  final LeaveThreadMessage message;

  @override
  Widget build(BuildContext context) {
    final start = message.proposedStartDate ?? '';
    final end = message.proposedEndDate ?? '';
    final days = message.proposedWorkingDayCount;
    final range = start == end
        ? formatDate(start, pattern: 'd MMM yyyy')
        : '${formatDate(start, pattern: 'd MMM')} - '
              '${formatDate(end, pattern: 'd MMM yyyy')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.calendarEdit,
            color: AppColors.primaryDark,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              days == null
                  ? range
                  : '$range • $days working ${days == 1 ? 'day' : 'days'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _messageTypeLabel(String value) {
  return switch (value) {
    'REQUEST' => 'Original request',
    'COMMENT' => 'Comment',
    'PROPOSAL' => 'Date proposal',
    'ACCEPTANCE' => 'Proposal accepted',
    'DIRECT_APPROVAL' => 'Approved',
    'REJECTION' => 'Rejected',
    'CANCELLATION' => 'Cancelled',
    _ => sentenceCaseStatus(value),
  };
}

IconData _messageTypeIcon(String value) {
  return switch (value) {
    'PROPOSAL' => AppIcons.calendarEdit,
    'ACCEPTANCE' || 'DIRECT_APPROVAL' => AppIcons.check,
    'REJECTION' || 'CANCELLATION' => AppIcons.closeCircle,
    'REQUEST' => AppIcons.calendarSearch,
    _ => AppIcons.chat,
  };
}

Color _messageTypeColor(String value) {
  return switch (value) {
    'PROPOSAL' => AppColors.warningDark,
    'ACCEPTANCE' || 'DIRECT_APPROVAL' => AppColors.success,
    'REJECTION' || 'CANCELLATION' => AppColors.danger,
    _ => AppColors.primaryDark,
  };
}
