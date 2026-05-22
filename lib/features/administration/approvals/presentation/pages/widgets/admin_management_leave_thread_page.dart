part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _AdminLeaveThreadPage extends StatefulWidget {
  const _AdminLeaveThreadPage({required this.controller, required this.item});

  final AdminLeaveRequestsController controller;
  final AdminApprovalItem item;

  @override
  State<_AdminLeaveThreadPage> createState() => _AdminLeaveThreadPageState();
}

class _AdminLeaveThreadPageState extends State<_AdminLeaveThreadPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isProposal = false;
  DateTime? _proposedStartDate;
  DateTime? _proposedEndDate;

  String get _leaveRequestId => widget.item.id;

  String get _employeeId => widget.item.employeeId;

  bool get _isPending => widget.item.status == 'PENDING';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Leave Thread',
              showDivider: true,
              background: Colors.white,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: _buildRequestSummary(context),
            ),
            Expanded(
              child: Obx(() {
                final thread = widget.controller.threadFor(_leaveRequestId);
                final loading = widget.controller.isThreadLoading(
                  _leaveRequestId,
                );

                return Column(
                  children: [
                    if (loading && thread != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            color: AppColors.primaryDark,
                            backgroundColor: AppColors.border,
                          ),
                        ),
                      ),
                    Expanded(child: _buildMessages(context, thread, loading)),
                    if (_isPending)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                        child: _buildComposer(context),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummary(BuildContext context) {
    final employeeName = widget.item.employeeName;
    final employeeEmail = widget.item.employeeEmail;
    final rawReason = widget.item.reason;
    final reason = stripLeavePrefix(rawReason);
    final leaveType = inferLeaveType(rawReason);
    final status = widget.item.status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusSoftColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.leaves,
                  size: 18,
                  color: statusColor(status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeeEmail.isEmpty
                          ? _adminLeaveRangeSummary(widget.item)
                          : employeeEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusChip(
                label: _statusLabel(status),
                status: status,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminApprovalSummaryMetric(
            label: 'LEAVE TYPE',
            value: leaveType,
            valueColor: AppColors.primaryDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                AppIcons.calendarOutline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _adminLeaveRangeSummary(widget.item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildReasonPreview(context, reason),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonPreview(BuildContext context, String reason) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REASON',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        _ExpandableThreadText(
          text: reason,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          expandedMaxHeight: 160,
        ),
      ],
    );
  }

  Widget _buildMessages(
    BuildContext context,
    LeaveThread? thread,
    bool loading,
  ) {
    if (loading && thread == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (thread == null || thread.messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        children: const [
          EmptyInfoCard(
            title: 'No thread yet',
            message: 'Messages for this leave request will appear here.',
            icon: AppIcons.chat,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: thread.messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = thread.messages[index];
        return _AdminLeaveThreadMessageTile(
          message: message,
          onAccept: _isPending && _canAccept(message)
              ? () => _acceptProposal(context, message)
              : null,
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    final submitting = widget.controller.isThreadSubmitting(_leaveRequestId);

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
                  child: _AdminThreadDateInput(
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
                  child: _AdminThreadDateInput(
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

  bool _canAccept(LeaveThreadMessage message) {
    return message.isProposal && message.actorUserId == _employeeId;
  }

  Future<void> _sendMessage(BuildContext context) async {
    final message = _messageController.text.trim();

    if (_isProposal &&
        (_proposedStartDate == null || _proposedEndDate == null)) {
      _showSnack(context, 'Choose both proposed dates.', isError: true);
      return;
    }

    if (!_isProposal && message.isEmpty) {
      _showSnack(context, 'Write a comment first.', isError: true);
      return;
    }

    if (_isProposal && _proposedEndDate!.isBefore(_proposedStartDate!)) {
      _showSnack(
        context,
        'Proposed end date cannot be before the start date.',
        isError: true,
      );
      return;
    }

    final error = await widget.controller.createThreadMessage(
      leaveRequestId: _leaveRequestId,
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
      _showSnack(context, error, isError: true);
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
    final error = await widget.controller.acceptThreadProposal(
      leaveRequestId: _leaveRequestId,
      messageId: message.id,
    );

    if (!context.mounted) return;
    if (error != null) {
      _showSnack(context, error, isError: true);
      return;
    }

    _showSnack(context, 'Proposal accepted.', isError: false);
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
}
