part of '../leaves_page.dart';

class _LeaveRequestTile extends StatefulWidget {
  const _LeaveRequestTile({
    required this.request,
    required this.isCancelling,
    required this.onOpenThread,
    this.onCancel,
  });

  final LeaveRequest request;
  final bool isCancelling;
  final VoidCallback onOpenThread;
  final VoidCallback? onCancel;

  @override
  State<_LeaveRequestTile> createState() => _LeaveRequestTileState();
}

class _LeaveRequestTileState extends State<_LeaveRequestTile> {
  static final BorderRadius _cardRadius = BorderRadius.circular(18);
  bool _showDetails = false;

  @override
  void didUpdateWidget(covariant _LeaveRequestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id) {
      _showDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final type = inferLeaveType(request.reason);
    final reason = stripLeavePrefix(request.reason).trim();

    final statusKey = request.status.toLowerCase();
    final badgeColor = statusColor(statusKey);
    final surfaceColor = statusSoftColor(statusKey);

    final actionNote = request.actionNote?.trim() ?? '';
    final actionBy = request.actionBy?.displayName.trim();
    final actionByLabel = actionBy == null || actionBy.isEmpty
        ? null
        : actionBy;
    final hasDetail =
        reason.isNotEmpty ||
        actionNote.isNotEmpty ||
        actionByLabel != null ||
        request.hasApprovedDateOverride;
    final canRevealDetails = hasDetail;
    final canCancel = widget.onCancel != null && !widget.isCancelling;

    return ClipRRect(
      borderRadius: _cardRadius,
      child: Dismissible(
        key: ValueKey<String>('leave-request-${request.id}'),
        direction: _dismissDirection(
          canRevealDetails: canRevealDetails,
          canCancel: canCancel,
        ),
        dismissThresholds: const <DismissDirection, double>{
          DismissDirection.startToEnd: 0.22,
          DismissDirection.endToStart: 0.22,
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (!canRevealDetails) return false;
            setState(() => _showDetails = !_showDetails);
            return false;
          }

          if (direction == DismissDirection.endToStart && canCancel) {
            widget.onCancel?.call();
          }
          return false;
        },
        background: _SwipeBackground(
          alignment: Alignment.centerLeft,
          icon: AppIcons.arrowForward,
          label: _showDetails ? 'Hide details' : 'Show details',
          backgroundColor: const Color(0xFFE0F2FE),
          foregroundColor: AppColors.infoDark,
          isVisible: canRevealDetails,
        ),
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight,
          icon: AppIcons.closeCircle,
          label: widget.isCancelling ? 'Cancelling...' : 'Cancel request',
          backgroundColor: const Color(0xFFFEE2E2),
          foregroundColor: AppColors.dangerDark,
          isVisible: canCancel,
        ),
        child: Container(
          decoration: AppTheme.cardDecoration(
            radius: _cardRadius,
            borderColor: const Color(0x0D1D3C8B),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          statusIcon(statusKey),
                          color: badgeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _summaryLabel(request),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              sentenceCaseStatus(request.status),
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRelative(request.createdAt),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                          if (widget.isCancelling) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Cancelling',
                                    style: TextStyle(
                                      color: AppColors.dangerDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (_showDetails && hasDetail) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reason.isNotEmpty)
                            _DetailLine(
                              title: 'Reason',
                              icon: AppIcons.calendarSearch,
                              child: _ExpandableText(text: reason),
                            ),
                          if (actionNote.isNotEmpty) ...[
                            if (reason.isNotEmpty) const SizedBox(height: 14),
                            _DetailLine(
                              title: 'Action Note',
                              icon: AppIcons.trendUp,
                              child: Text(
                                actionNote,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                          if (actionByLabel != null) ...[
                            if (reason.isNotEmpty || actionNote.isNotEmpty)
                              const SizedBox(height: 14),
                            _DetailLine(
                              title: _actionByTitle(statusKey),
                              icon: AppIcons.profile,
                              child: Text(
                                actionByLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                          if (request.hasApprovedDateOverride) ...[
                            if (reason.isNotEmpty ||
                                actionNote.isNotEmpty ||
                                actionByLabel != null)
                              const SizedBox(height: 14),
                            _DetailLine(
                              title: 'Approved dates',
                              icon: AppIcons.calendarTick,
                              child: Text(
                                _approvedDateSummary(request),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: widget.onOpenThread,
                      icon: const Icon(AppIcons.chat, size: 17),
                      label: const Text('Thread'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DismissDirection _dismissDirection({
    required bool canRevealDetails,
    required bool canCancel,
  }) {
    if (canRevealDetails && canCancel) return DismissDirection.horizontal;
    if (canRevealDetails) return DismissDirection.startToEnd;
    if (canCancel) return DismissDirection.endToStart;
    return DismissDirection.none;
  }

  String _summaryLabel(LeaveRequest request) {
    final parts = <String>[_effectiveDateRangeLabel(request)];
    if (request.effectiveWorkingDayCount > 0) {
      final suffix = request.effectiveWorkingDayCount == 1 ? 'day' : 'days';
      parts.add('${request.effectiveWorkingDayCount} $suffix');
    }
    if (request.hasApprovedDateOverride) parts.add('Adjusted');
    return parts.join(' • ');
  }

  String _effectiveDateRangeLabel(LeaveRequest request) {
    if (request.effectiveStartDate == request.effectiveEndDate) {
      return formatDate(request.effectiveStartDate, pattern: 'd MMM yyyy');
    }

    return '${formatDate(request.effectiveStartDate, pattern: 'd MMM')} - '
        '${formatDate(request.effectiveEndDate, pattern: 'd MMM')}';
  }

  String _approvedDateSummary(LeaveRequest request) {
    final days = request.effectiveWorkingDayCount;
    final suffix = days == 1 ? 'day' : 'days';
    final original = request.startDate == request.endDate
        ? formatDate(request.startDate, pattern: 'd MMM yyyy')
        : '${formatDate(request.startDate, pattern: 'd MMM')} - '
              '${formatDate(request.endDate, pattern: 'd MMM yyyy')}';
    return '${_effectiveDateRangeLabel(request)} • $days $suffix\nOriginally $original';
  }

  String _actionByTitle(String status) {
    switch (status) {
      case 'approved':
        return 'Approved by';
      case 'rejected':
        return 'Rejected by';
      case 'cancelled':
        return 'Cancelled by';
      default:
        return 'Action by';
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
