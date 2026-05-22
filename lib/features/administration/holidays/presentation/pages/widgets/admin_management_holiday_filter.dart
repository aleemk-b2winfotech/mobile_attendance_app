part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _HolidayFilterBar extends StatefulWidget {
  const _HolidayFilterBar({
    required this.startDate,
    required this.endDate,
    required this.includeDeleted,
    required this.onApply,
  });

  final String startDate;
  final String endDate;
  final bool includeDeleted;
  final Future<void> Function(
    String startDate,
    String endDate,
    bool includeDeleted,
  )
  onApply;

  @override
  State<_HolidayFilterBar> createState() => _HolidayFilterBarState();
}

class _HolidayFilterBarState extends State<_HolidayFilterBar> {
  bool _expanded = false;
  late String _draftStartDate;
  late String _draftEndDate;
  late bool _draftIncludeDeleted;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _syncDrafts();
  }

  @override
  void didUpdateWidget(covariant _HolidayFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_expanded &&
        (oldWidget.startDate != widget.startDate ||
            oldWidget.endDate != widget.endDate ||
            oldWidget.includeDeleted != widget.includeDeleted)) {
      _syncDrafts();
    }
  }

  void _syncDrafts() {
    _draftStartDate = widget.startDate;
    _draftEndDate = widget.endDate;
    _draftIncludeDeleted = widget.includeDeleted;
  }

  @override
  Widget build(BuildContext context) {
    final rangeLabel =
        '${_shortDate(widget.startDate)} - ${_shortDate(widget.endDate)}';

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
                          AppIcons.calendarOutline,
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
                              widget.includeDeleted
                                  ? 'Including deleted'
                                  : 'Active holidays',
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
                secondChild: _HolidayInlineFilters(
                  startDate: _draftStartDate,
                  endDate: _draftEndDate,
                  includeDeleted: _draftIncludeDeleted,
                  isApplying: _isApplying,
                  onStart: (value) => setState(() => _draftStartDate = value),
                  onEnd: (value) => setState(() => _draftEndDate = value),
                  onIncludeDeleted: (value) =>
                      setState(() => _draftIncludeDeleted = value),
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
    await widget.onApply(_draftStartDate, _draftEndDate, _draftIncludeDeleted);
    if (!mounted) return;
    setState(() {
      _isApplying = false;
      _expanded = false;
    });
  }
}

class _HolidayInlineFilters extends StatelessWidget {
  const _HolidayInlineFilters({
    required this.startDate,
    required this.endDate,
    required this.includeDeleted,
    required this.isApplying,
    required this.onStart,
    required this.onEnd,
    required this.onIncludeDeleted,
    required this.onApply,
  });

  final String startDate;
  final String endDate;
  final bool includeDeleted;
  final bool isApplying;
  final ValueChanged<String> onStart;
  final ValueChanged<String> onEnd;
  final ValueChanged<bool> onIncludeDeleted;
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
          const SizedBox(height: 6),
          SwitchListTile(
            value: includeDeleted,
            title: const Text('Include deleted'),
            contentPadding: EdgeInsets.zero,
            onChanged: onIncludeDeleted,
          ),
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
