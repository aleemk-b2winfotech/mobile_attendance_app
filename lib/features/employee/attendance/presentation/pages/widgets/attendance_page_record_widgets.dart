part of '../attendance_page.dart';

class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final statusKey = day.attendanceState == 'regularized'
        ? 'present'
        : day.attendanceState;
    final iconTint = statusColor(statusKey);
    final iconSurface = statusSoftColor(statusKey);
    final hasRegularization = day.hasRegularizationLink;
    final hasLeave = day.hasLeaveLink;
    final descriptor = _attendanceDayDescriptor(
      day,
      hasRegularization: hasRegularization,
      hasLeave: hasLeave,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(borderColor: const Color(0x0D1D3C8B)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(statusIcon(statusKey), size: 17, color: iconTint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(day.date, pattern: 'EEE, MMM d'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descriptor.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusSoftColor(statusKey),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  sentenceCaseStatus(statusKey),
                  style: TextStyle(
                    color: statusColor(statusKey),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (hasRegularization) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AttendanceContextChip(
                    label: hasLeave ? 'Leave overridden' : 'Overridden',
                    color: AppColors.primaryDark,
                    backgroundColor: const Color(0xFFE0E7FF),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x0D1D3C8B))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricBlock(
                  label: 'CHECK IN',
                  value: formatClock(day.punchInAt),
                ),
                _MetricBlock(
                  label: 'CHECK OUT',
                  value: formatClock(day.punchOutAt),
                ),
                _MetricBlock(
                  label: 'DURATION',
                  value: formatMinutes(day.workedMinutes),
                  valueColor: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _AttendanceContextChip extends StatelessWidget {
  const _AttendanceContextChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _attendanceDayDescriptor(
  AttendanceDay day, {
  required bool hasRegularization,
  required bool hasLeave,
}) {
  if (hasRegularization && hasLeave) return 'Leave overridden';
  if (hasRegularization) return 'Overridden';

  return attendanceDescriptor(
    day.attendanceState,
    workedMinutes: day.workedMinutes,
  );
}
