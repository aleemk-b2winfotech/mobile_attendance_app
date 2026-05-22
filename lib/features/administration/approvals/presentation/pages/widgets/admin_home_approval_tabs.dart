part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _ApprovalFiltersPanel extends StatefulWidget {
  const _ApprovalFiltersPanel({
    required this.controller,
    required this.activeTab,
  });

  final AdminDashboardController controller;
  final AdminApprovalTab activeTab;

  @override
  State<_ApprovalFiltersPanel> createState() => _ApprovalFiltersPanelState();
}

class _ApprovalFiltersPanelState extends State<_ApprovalFiltersPanel> {
  bool _expanded = true;
  late String _draftStatus;
  late String _draftStartDate;
  late String _draftEndDate;
  late TextEditingController _searchController;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _syncDrafts();
  }

  @override
  void didUpdateWidget(covariant _ApprovalFiltersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tabChanged = oldWidget.activeTab != widget.activeTab;
    if (tabChanged) {
      _expanded = true;
    }
    if (!_expanded || tabChanged) {
      _syncDrafts();
    }
  }

  void _syncDrafts() {
    final controller = widget.controller;
    _draftStatus = controller.activeApprovalStatus;
    _draftStartDate = controller.leaveApprovalStartDate.value;
    _draftEndDate = controller.leaveApprovalEndDate.value;
    _searchController = widget.activeTab == AdminApprovalTab.leave
        ? controller.leaveApprovalSearchController
        : controller.deviceApprovalSearchController;
  }

  @override
  Widget build(BuildContext context) {
    final isLeave = widget.activeTab == AdminApprovalTab.leave;
    final statusLabel = _approvalStatusLabel(
      widget.controller.activeApprovalStatus,
    );
    final searchText = _searchController.text.trim();
    final summary = isLeave
        ? '${_homeApprovalShortDate(widget.controller.leaveApprovalStartDate.value)} - ${_homeApprovalShortDate(widget.controller.leaveApprovalEndDate.value)}'
        : (searchText.isEmpty ? 'Search by employee' : 'Search: $searchText');

    return Container(
      decoration: AppTheme.cardDecoration(
        borderColor: const Color(0x0D1D3C8B),
        radius: BorderRadius.circular(16),
        shadows: const [],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: _expanded ? 'Hide filters' : 'Show filters',
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
                  if (isLeave) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _ApprovalDateButton(
                            label: 'Start',
                            value: _draftStartDate,
                            onChanged: (value) =>
                                setState(() => _draftStartDate = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ApprovalDateButton(
                            label: 'End',
                            value: _draftEndDate,
                            onChanged: (value) =>
                                setState(() => _draftEndDate = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: _draftStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: widget.controller
                        .approvalStatusesFor(widget.activeTab)
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(_approvalStatusLabel(status)),
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
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search employee',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _apply(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _isApplying ? null : _apply,
                    child: _isApplying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
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
    );
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    try {
      if (widget.activeTab == AdminApprovalTab.leave) {
        await widget.controller.applyLeaveApprovalFilters(
          status: _draftStatus,
          startDate: _draftStartDate,
          endDate: _draftEndDate,
          search: _searchController.text,
        );
      } else {
        await widget.controller.applyDeviceApprovalFilters(
          status: _draftStatus,
          search: _searchController.text,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}

class _ApprovalDateButton extends StatelessWidget {
  const _ApprovalDateButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final initialDate = DateTime.tryParse(value) ?? DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (selected == null) return;
        onChanged(DateFormat('yyyy-MM-dd').format(selected));
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.calendarOutline, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  _homeApprovalShortDate(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _homeApprovalShortDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd MMM').format(date);
}

class _ApprovalTabSwitcher extends StatelessWidget {
  const _ApprovalTabSwitcher({
    required this.selectedTab,
    required this.onChanged,
  });

  final AdminApprovalTab selectedTab;
  final ValueChanged<AdminApprovalTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _ApprovalTabButton(
            label: 'Leave',
            selected: selectedTab == AdminApprovalTab.leave,
            onTap: () => onChanged(AdminApprovalTab.leave),
          ),
          const SizedBox(width: 5),
          _ApprovalTabButton(
            label: 'Device',
            selected: selectedTab == AdminApprovalTab.device,
            onTap: () => onChanged(AdminApprovalTab.device),
          ),
        ],
      ),
    );
  }
}

String _approvalCountMessage({
  required int count,
  required String status,
  required String statusLabel,
  required String requestLabel,
}) {
  final pluralRequest = count == 1 ? requestLabel : '${requestLabel}s';
  final filterLabel = status == 'ALL' ? '' : '${statusLabel.toLowerCase()} ';
  return '$count $filterLabel$pluralRequest';
}

String _approvalEmptyMessage({
  required String status,
  required String requestLabel,
}) {
  final pluralRequest = '${requestLabel}s';
  if (status == 'ALL') return 'All $pluralRequest will appear here.';
  return '${_approvalStatusLabel(status)} $pluralRequest will appear here.';
}

String _approvalStatusLabel(String value) {
  return switch (value) {
    'ALL' => 'All',
    'PENDING' => 'Pending',
    'APPROVED' => 'Approved',
    'REJECTED' => 'Rejected',
    'CANCELLED' => 'Cancelled',
    _ => value,
  };
}

IconData _approvalStatusIcon(String status) {
  return switch (status) {
    'APPROVED' => AppIcons.present,
    'PENDING' => AppIcons.pending,
    'REJECTED' => AppIcons.absent,
    'CANCELLED' => AppIcons.closeCircle,
    _ => AppIcons.checkSquare,
  };
}

Color _approvalStatusColor(String status) {
  return switch (status) {
    'APPROVED' => AppColors.successDark,
    'PENDING' => AppColors.warningDark,
    'REJECTED' => AppColors.dangerDark,
    'CANCELLED' => AppColors.textSecondary,
    _ => AppColors.primaryDark,
  };
}

Color _approvalStatusSoftColor(String status) {
  return switch (status) {
    'APPROVED' => const Color(0xFFD1FAE5),
    'PENDING' => const Color(0xFFFEF3C7),
    'REJECTED' => const Color(0xFFFECACA),
    'CANCELLED' => const Color(0xFFF1F5F9),
    _ => const Color(0xFFE2E8F0),
  };
}

class _ApprovalTabButton extends StatelessWidget {
  const _ApprovalTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : const [],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
