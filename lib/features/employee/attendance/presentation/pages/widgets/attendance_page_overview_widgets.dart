part of '../attendance_page.dart';

class _AttendanceLoading extends StatelessWidget {
  const _AttendanceLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 120),
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                child: Container(
                  height: 108,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 142,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final AttendanceSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Present',
            value: summary?.presentDays ?? 0,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _SummaryCard(label: 'Half Day', value: summary?.halfDays ?? 0),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _SummaryCard(label: 'Absent', value: summary?.absentDays ?? 0),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.selectedMonth,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime selectedMonth;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formatMonth(selectedMonth),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          _MonthIconButton(icon: AppIcons.arrowBack, onTap: onPrevious),
          _MonthIconButton(
            icon: AppIcons.arrowForward,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _MonthIconButton extends StatelessWidget {
  const _MonthIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.38 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _StatusFilterStrip extends StatelessWidget {
  const _StatusFilterStrip({
    required this.selectedStatuses,
    required this.onToggle,
    required this.onClear,
  });

  final Set<String> selectedStatuses;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedStatuses.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: AppIcons.checkSquare,
            active: !hasSelection,
            onTap: onClear,
          ),
          for (final entry in AttendanceFilterState.labels.entries) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: entry.value,
              icon: _filterIcon(entry.key),
              active: selectedStatuses.contains(entry.key),
              onTap: () => onToggle(entry.key),
            ),
          ],
          if (hasSelection) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Clear',
              icon: AppIcons.close,
              active: false,
              onTap: onClear,
            ),
          ],
        ],
      ),
    );
  }

  IconData _filterIcon(String status) {
    switch (status) {
      case 'present':
        return AppIcons.present;
      case 'halfDay':
        return AppIcons.halfDay;
      case 'absent':
        return AppIcons.absent;
      case 'overtime':
        return AppIcons.trendUp;
      case 'regularized':
        return AppIcons.calendarEdit;
      default:
        return AppIcons.checkSquare;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.border,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
