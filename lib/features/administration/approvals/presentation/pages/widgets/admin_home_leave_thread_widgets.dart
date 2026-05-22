part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _AdminHomeLeaveThreadMessageTile extends StatelessWidget {
  const _AdminHomeLeaveThreadMessageTile({
    required this.message,
    this.onAccept,
    this.onApproveOriginal,
    this.onRejectOriginal,
    this.isOriginalActionBusy = false,
  });

  final LeaveThreadMessage message;
  final VoidCallback? onAccept;
  final VoidCallback? onApproveOriginal;
  final VoidCallback? onRejectOriginal;
  final bool isOriginalActionBusy;

  @override
  Widget build(BuildContext context) {
    final note = message.message?.trim() ?? '';
    final showNote = note.isNotEmpty && message.messageType != 'REQUEST';
    final actor = message.actor?.fullName.trim();
    final actorLabel = actor == null || actor.isEmpty ? 'User' : actor;
    final accepting = Get.find<AdminDashboardController>().isAcceptingProposal(
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
                  color: _homeLeaveThreadTypeColor(
                    message.messageType,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _homeLeaveThreadTypeIcon(message.messageType),
                  color: _homeLeaveThreadTypeColor(message.messageType),
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _homeLeaveThreadTypeLabel(message.messageType),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$actorLabel • ${_homeFormatDateTime(message.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showNote) ...[
            const SizedBox(height: 10),
            _ExpandableThreadText(
              text: note,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (message.hasProposedDates) ...[
            const SizedBox(height: 10),
            _AdminHomeThreadDateProposal(message: message),
          ],
          if (onApproveOriginal != null && onRejectOriginal != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isOriginalActionBusy ? null : onRejectOriginal,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isOriginalActionBusy ? null : onApproveOriginal,
                    child: isOriginalActionBusy
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
            ),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: accepting ? null : onAccept,
                icon: accepting
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

class _ExpandableThreadText extends StatefulWidget {
  const _ExpandableThreadText({
    required this.text,
    required this.style,
    this.expandedMaxHeight,
  });

  final String text;
  final TextStyle? style;
  final double? expandedMaxHeight;

  @override
  State<_ExpandableThreadText> createState() => _ExpandableThreadTextState();
}

class _ExpandableThreadTextState extends State<_ExpandableThreadText> {
  static const _collapsedMaxLines = 2;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return _plainText(
            widget.text,
            maxLines: _expanded ? null : _collapsedMaxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          );
        }

        final textDirection = Directionality.of(context);
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: _collapsedMaxLines,
          textDirection: textDirection,
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return _fullWidth(_plainText(widget.text), constraints.maxWidth);
        }

        final richText = _fullWidth(
          Text.rich(
            _expanded
                ? _expandedSpan()
                : _collapsedSpan(
                    maxWidth: constraints.maxWidth,
                    textDirection: textDirection,
                  ),
            maxLines: _expanded ? null : _collapsedMaxLines,
            overflow: TextOverflow.clip,
          ),
          constraints.maxWidth,
        );
        final child = _expanded && widget.expandedMaxHeight != null
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.expandedMaxHeight!,
                ),
                child: SingleChildScrollView(child: richText),
              )
            : richText;

        return Semantics(
          button: true,
          label: _expanded ? 'Collapse text' : 'Expand text',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: child,
          ),
        );
      },
    );
  }

  Widget _plainText(
    String text, {
    int? maxLines,
    TextOverflow overflow = TextOverflow.visible,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: widget.style,
    );
  }

  Widget _fullWidth(Widget child, double width) {
    return SizedBox(width: width, child: child);
  }

  TextSpan _expandedSpan() {
    return TextSpan(
      style: widget.style,
      children: [
        TextSpan(text: widget.text),
        TextSpan(text: ' less', style: _affordanceStyle()),
      ],
    );
  }

  TextSpan _collapsedSpan({
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    var low = 0;
    var high = widget.text.length;
    var best = '';

    while (low <= high) {
      final mid = (low + high) >> 1;
      final candidate = widget.text.substring(0, mid).trimRight();
      final painter = TextPainter(
        text: _collapsedTextSpan(candidate),
        maxLines: _collapsedMaxLines,
        textDirection: textDirection,
      )..layout(maxWidth: maxWidth);

      if (painter.didExceedMaxLines) {
        high = mid - 1;
      } else {
        best = candidate;
        low = mid + 1;
      }
    }

    return _collapsedTextSpan(best);
  }

  TextSpan _collapsedTextSpan(String visibleText) {
    return TextSpan(
      style: widget.style,
      children: [
        TextSpan(text: visibleText),
        const TextSpan(text: '... '),
        TextSpan(text: 'more', style: _affordanceStyle()),
      ],
    );
  }

  TextStyle? _affordanceStyle() {
    return widget.style?.copyWith(
      color: AppColors.primaryDark,
      fontWeight: FontWeight.w700,
    );
  }
}

class _AdminHomeThreadDateProposal extends StatelessWidget {
  const _AdminHomeThreadDateProposal({required this.message});

  final LeaveThreadMessage message;

  @override
  Widget build(BuildContext context) {
    final range = _homeDateRange(
      message.proposedStartDate,
      message.proposedEndDate,
    );
    final days = message.proposedWorkingDayCount;

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

class _AdminHomeThreadDateInput extends StatelessWidget {
  const _AdminHomeThreadDateInput({
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
          color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

String _homeLeaveThreadTypeLabel(String value) {
  return switch (value) {
    'REQUEST' => 'Original request',
    'COMMENT' => 'Comment',
    'PROPOSAL' => 'Date proposal',
    'ACCEPTANCE' => 'Proposal accepted',
    'DIRECT_APPROVAL' => 'Approved',
    'REJECTION' => 'Rejected',
    'CANCELLATION' => 'Cancelled',
    _ => value,
  };
}

IconData _homeLeaveThreadTypeIcon(String value) {
  return switch (value) {
    'PROPOSAL' => AppIcons.calendarEdit,
    'ACCEPTANCE' || 'DIRECT_APPROVAL' => AppIcons.check,
    'REJECTION' || 'CANCELLATION' => AppIcons.closeCircle,
    'REQUEST' => AppIcons.calendarSearch,
    _ => AppIcons.chat,
  };
}

Color _homeLeaveThreadTypeColor(String value) {
  return switch (value) {
    'PROPOSAL' => AppColors.warningDark,
    'ACCEPTANCE' || 'DIRECT_APPROVAL' => AppColors.success,
    'REJECTION' || 'CANCELLATION' => AppColors.danger,
    _ => AppColors.primaryDark,
  };
}

String _homeFormatDateTime(Object? value) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) return '';
  final date = DateTime.tryParse(text);
  if (date == null) return text;
  return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
}

String _homeDateRange(Object? startValue, Object? endValue) {
  final startText = _homeIsoDay(startValue);
  final endText = _homeIsoDay(endValue);
  final start = DateTime.tryParse(startText)?.toLocal();
  final end = DateTime.tryParse(endText)?.toLocal();

  if (start == null && end == null) return '-';
  if (start == null) return DateFormat('MMM d, yyyy').format(end!);
  if (end == null || DateUtils.isSameDay(start, end)) {
    return DateFormat('MMM d, yyyy').format(start);
  }
  if (start.year == end.year) {
    return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }
  return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
}

String _homeLeaveApprovalDate(AdminApprovalItem item) {
  final parts = item.title.split(' to ');
  final start = parts.isEmpty ? item.title : parts.first;
  final end = parts.length > 1 ? parts.last : start;
  return _homeDateRange(start, end);
}

String _homeLeaveReason(AdminApprovalItem item) {
  final lines = item.detail.trim().split('\n');
  if (lines.isEmpty) return '';

  final lastLine = lines.last.trim();
  final workingDaysPattern = RegExp(r'^\d+\s+working\s+days?$');
  if (workingDaysPattern.hasMatch(lastLine)) {
    lines.removeLast();
  }
  return lines.join('\n').trim();
}

String _homeIsoDay(Object? value) {
  final text = value?.toString() ?? '';
  if (text.length <= 10) return text;
  return text.substring(0, 10);
}
