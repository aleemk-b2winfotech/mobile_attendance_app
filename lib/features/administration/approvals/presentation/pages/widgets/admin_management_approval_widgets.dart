part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _ApprovalsListPage extends StatelessWidget {
  const _ApprovalsListPage({
    required this.title,
    required this.rows,
    required this.meta,
    required this.loading,
    required this.error,
    required this.search,
    required this.status,
    required this.statuses,
    required this.onStatus,
    required this.onSearch,
    required this.onRefresh,
    required this.onPage,
    required this.itemBuilder,
    this.filters,
  });

  final String title;
  final List<AdminApprovalItem> rows;
  final AdminPaginationMeta meta;
  final bool loading;
  final String? error;
  final TextEditingController search;
  final String status;
  final List<String> statuses;
  final ValueChanged<String> onStatus;
  final VoidCallback onSearch;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onPage;
  final Widget Function(AdminApprovalItem row) itemBuilder;
  final Widget? filters;

  @override
  Widget build(BuildContext context) {
    return _AdminPageFrame(
      title: title,
      child: Column(
        children: [
          filters ??
              _FilterBand(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statuses
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(_statusLabel(status)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) onStatus(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: search,
                    decoration: const InputDecoration(
                      hintText: 'Search employee',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ],
              ),
          Expanded(
            child: _PagedBody(
              loading: loading,
              error: error,
              isEmpty: rows.isEmpty,
              onRetry: onSearch,
              emptyTitle: 'No requests',
              emptyMessage: 'Nothing matches the current filters.',
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
                  itemCount: rows.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == rows.length) {
                      return _Pager(meta: meta, onPage: onPage);
                    }
                    return itemBuilder(rows[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveApprovalFilterBar extends StatefulWidget {
  const _LeaveApprovalFilterBar({
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.statuses,
    required this.search,
    required this.onApply,
    required this.onSearch,
  });

  final String startDate;
  final String endDate;
  final String status;
  final List<String> statuses;
  final TextEditingController search;
  final Future<void> Function(String startDate, String endDate, String status)
  onApply;
  final VoidCallback onSearch;

  @override
  State<_LeaveApprovalFilterBar> createState() =>
      _LeaveApprovalFilterBarState();
}

class _LeaveApprovalFilterBarState extends State<_LeaveApprovalFilterBar> {
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
  void didUpdateWidget(covariant _LeaveApprovalFilterBar oldWidget) {
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
                              _statusLabel(widget.status),
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
                secondChild: Container(
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
                              value: _draftStartDate,
                              onChanged: (value) =>
                                  setState(() => _draftStartDate = value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateButton(
                              label: 'End',
                              value: _draftEndDate,
                              onChanged: (value) =>
                                  setState(() => _draftEndDate = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _draftStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: widget.statuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(_statusLabel(status)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _draftStatus = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: widget.search,
                        decoration: const InputDecoration(
                          hintText: 'Search employee',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => widget.onSearch(),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _isApplying ? null : _apply,
                        child: _isApplying
                            ? const ButtonSpinner()
                            : const Text('Apply Filters'),
                      ),
                    ],
                  ),
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

class _AdminApprovalActionCard extends StatelessWidget {
  const _AdminApprovalActionCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.onThread,
  });

  final AdminApprovalItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onThread;

  @override
  Widget build(BuildContext context) {
    final pending = item.status == 'PENDING';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.employeeName,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              StatusChip(
                label: _statusLabel(item.status),
                status: item.status,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.employeeEmail,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Text(item.title, style: Theme.of(context).textTheme.bodyMedium),
          if (item.detail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.detail,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onThread != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onThread,
                      icon: const Icon(AppIcons.chat, size: 15),
                      label: const Text('Thread'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ] else if (onThread != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onThread,
                icon: const Icon(AppIcons.chat, size: 16),
                label: const Text('Thread'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminApprovalSummaryMetric extends StatelessWidget {
  const _AdminApprovalSummaryMetric({
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
