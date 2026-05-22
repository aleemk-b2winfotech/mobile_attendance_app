part of '../leaves_page.dart';

class _LeaveFilterStrip extends StatelessWidget {
  const _LeaveFilterStrip({
    required this.selectedStatus,
    required this.onChanged,
    this.isLoading = false,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

  static const Map<String, String> labels = <String, String>{
    'PENDING': 'Pending',
    'APPROVED': 'Approved',
    'REJECTED': 'Rejected',
    'CANCELLED': 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Opacity(
        opacity: isLoading ? 0.72 : 1,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                icon: AppIcons.checkSquare,
                color: AppColors.primaryDark,
                selected: selectedStatus == null,
                onTap: () => onChanged(null),
              ),
              for (final entry in labels.entries) ...[
                const SizedBox(width: 8),
                _FilterChip(
                  label: entry.value,
                  icon: _statusIcon(entry.key),
                  color: statusColor(entry.key),
                  selected: selectedStatus == entry.key,
                  onTap: () => onChanged(entry.key),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return AppIcons.present;
      case 'PENDING':
        return AppIcons.pending;
      case 'REJECTED':
        return AppIcons.absent;
      case 'CANCELLED':
        return AppIcons.close;
      default:
        return AppIcons.checkSquare;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
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
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.16)
                : AppColors.border.withValues(alpha: 0.92),
          ),
          boxShadow: selected
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
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
