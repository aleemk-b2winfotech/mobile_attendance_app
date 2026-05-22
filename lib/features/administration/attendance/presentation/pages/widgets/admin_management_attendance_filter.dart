part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _AttendanceFilterBar extends StatefulWidget {
  const _AttendanceFilterBar({
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.onApply,
  });

  final String startDate;
  final String endDate;
  final String status;
  final Future<void> Function(String startDate, String endDate, String status)
  onApply;

  @override
  State<_AttendanceFilterBar> createState() => _AttendanceFilterBarState();
}

class _AttendanceFilterBarState extends State<_AttendanceFilterBar> {
  bool _expanded = false;
  late String _draftStartDate;
  late String _draftEndDate;
  late String _draftStatus;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _syncDrafts();
  }

  @override
  void didUpdateWidget(covariant _AttendanceFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded &&
        (oldWidget.startDate != widget.startDate ||
            oldWidget.endDate != widget.endDate ||
            oldWidget.status != widget.status)) {
      _syncDrafts();
    }
  }

  void _syncDrafts() {
    _draftStartDate = widget.startDate;
    _draftEndDate = widget.endDate;
    _draftStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final rangeLabel =
        '${_shortDate(widget.startDate)} - ${_shortDate(widget.endDate)}';
    final statusLabel = widget.status == 'all'
        ? 'All statuses'
        : _statusLabel(widget.status);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: AppTheme.cardDecoration(
            borderColor: const Color(0x0D1D3C8B),
            radius: BorderRadius.circular(14),
            shadows: const [],
          ),
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primaryDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rangeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              statusLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: _expanded ? 'Hide filters' : 'Filters',
                        onPressed: _toggleExpanded,
                        icon: Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.filter_list_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _AttendanceInlineFilters(
                  startDate: _draftStartDate,
                  endDate: _draftEndDate,
                  status: _draftStatus,
                  isApplying: _isApplying,
                  onStart: (value) => setState(() => _draftStartDate = value),
                  onEnd: (value) => setState(() => _draftEndDate = value),
                  onStatus: (value) =>
                      setState(() => _draftStatus = value ?? 'all'),
                  onApply: _apply,
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeOut,
                sizeCurve: Curves.easeOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      if (!_expanded) _syncDrafts();
      _expanded = !_expanded;
    });
  }

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    await widget.onApply(_draftStartDate, _draftEndDate, _draftStatus);
    if (!mounted) return;
    setState(() {
      _isApplying = false;
      _expanded = false;
    });
  }
}

class _AttendanceInlineFilters extends StatelessWidget {
  const _AttendanceInlineFilters({
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isApplying,
    required this.onStart,
    required this.onEnd,
    required this.onStatus,
    required this.onApply,
  });

  final String startDate;
  final String endDate;
  final String status;
  final bool isApplying;
  final ValueChanged<String> onStart;
  final ValueChanged<String> onEnd;
  final ValueChanged<String?> onStatus;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0D1D3C8B))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start',
                  value: startDate,
                  onChanged: onStart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'End',
                  value: endDate,
                  onChanged: onEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'halfDay', child: Text('Half day')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'working', child: Text('Working')),
              DropdownMenuItem(value: 'onLeave', child: Text('Leave')),
              DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
              DropdownMenuItem(
                value: 'regularized',
                child: Text('Regularized'),
              ),
            ],
            onChanged: onStatus,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isApplying ? null : onApply,
            child: isApplying
                ? const ButtonSpinner()
                : const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final date = DateTime.tryParse(value) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      icon: const Icon(AppIcons.calendarOutline, size: 16),
      label: Text('$label\n$value', textAlign: TextAlign.center),
    );
  }
}
