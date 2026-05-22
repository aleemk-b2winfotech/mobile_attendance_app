part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _AdminHomeLeaveThreadPage extends StatefulWidget {
  const _AdminHomeLeaveThreadPage({required this.item});

  final AdminApprovalItem item;

  @override
  State<_AdminHomeLeaveThreadPage> createState() =>
      _AdminHomeLeaveThreadPageState();
}

class _AdminHomeLeaveThreadPageState extends State<_AdminHomeLeaveThreadPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isProposal = false;
  DateTime? _proposedStartDate;
  DateTime? _proposedEndDate;

  AdminDashboardController get _controller =>
      Get.find<AdminDashboardController>();

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
                final thread = _controller.threadFor(widget.item.id);
                final loading = _controller.isThreadLoading(widget.item.id);

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
    final rawReason = _homeLeaveReason(widget.item);
    final reason = stripLeavePrefix(rawReason);
    final leaveType = inferLeaveType(rawReason);

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
                  color: _approvalStatusSoftColor(widget.item.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  AppIcons.leaves,
                  size: 18,
                  color: _approvalStatusColor(widget.item.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _homeLeaveApprovalDate(widget.item),
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
                label: _approvalStatusLabel(widget.item.status),
                status: widget.item.status,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminHomeApprovalMetricBlock(
            label: 'LEAVE TYPE',
            value: leaveType,
            valueColor: AppColors.primaryDark,
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 12),
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
          expandedMaxHeight: 200,
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
        final showOriginalActions =
            _isPending && message.messageType == 'REQUEST';
        final actionBusy = _controller.actionIds.contains(widget.item.id);

        return _AdminHomeLeaveThreadMessageTile(
          message: message,
          onAccept: _isPending && _canAccept(message)
              ? () => _acceptProposal(context, message)
              : null,
          onApproveOriginal: showOriginalActions
              ? () => _approveOriginalRequest(context)
              : null,
          onRejectOriginal: showOriginalActions
              ? () => _rejectOriginalRequest(context)
              : null,
          isOriginalActionBusy: actionBusy,
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    final submitting = _controller.isThreadSubmitting(widget.item.id);

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
                  child: _AdminHomeThreadDateInput(
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
                  child: _AdminHomeThreadDateInput(
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
    return message.isProposal && message.actorUserId == widget.item.employeeId;
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
      leaveRequestId: widget.item.id,
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
      leaveRequestId: widget.item.id,
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

  Future<void> _approveOriginalRequest(BuildContext context) async {
    final error = await _controller.approve(widget.item);

    if (!context.mounted) return;
    if (error != null) {
      _showSheetSnack(context, error, isError: true);
      return;
    }

    _showSheetSnack(context, 'Leave approved.', isError: false);
    Navigator.of(context).maybePop();
  }

  Future<void> _rejectOriginalRequest(BuildContext context) async {
    final note = await _askForAdminHomeRejectionNote(context);
    if (!context.mounted || note == null) return;

    final error = await _controller.reject(widget.item, note);

    if (!context.mounted) return;
    if (error != null) {
      _showSheetSnack(context, error, isError: true);
      return;
    }

    _showSheetSnack(context, 'Leave rejected.', isError: false);
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

  void _showSheetSnack(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    AppToast.show(message, isError: isError);
  }
}
