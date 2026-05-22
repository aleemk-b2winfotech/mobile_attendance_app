part of '../dashboard_page.dart';

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.data});

  final MonthAttendance data;

  @override
  Widget build(BuildContext context) {
    final estimatedMinutes = _monthWorkMinutes(
      presentDays: data.presentDays,
      // halfDays: data.halfDays,
      absentDays: data.absentDays,
      attendanceRate: data.attendancePercentage,
    );

    final trackedDays = data.presentDays + data.halfDays + data.absentDays;
    final deltaMinutes = trackedDays == 0
        ? 0
        : (trackedDays * 540) - estimatedMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          'Attendance and work-hour summary',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                color: AppColors.success,
                icon: AppIcons.present,
                title: 'Present Days',
                value: '${data.presentDays}',
                footnote: 'Active this month',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                color: AppColors.danger,
                icon: AppIcons.absent,
                title: 'Absent Days',
                value: '${data.absentDays}',
                footnote: 'Days missed',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                color: AppColors.info,
                icon: AppIcons.timer,
                title: 'Monthly Work',
                value: formatMinutes(estimatedMinutes),
                footnote: 'Estimated total',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                color: AppColors.warning,
                icon: AppIcons.leaves,
                title: 'Leaves',
                value: '${data.leaveDays} Days',
                footnote: 'Approved leaves',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                color: AppColors.textSecondary,
                icon: AppIcons.holiday,
                title: 'Holidays',
                value: '${data.holidayDays} Days',
                footnote: 'Holidays this month',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                color: AppColors.warning,
                icon: AppIcons.calendarOutline,
                title: 'Week Off',
                value: '${data.weeklyOffDays} Days',
                footnote: 'Week-offs this month',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _OvertimeSummary(deltaMinutes: deltaMinutes),
        const SizedBox(height: 16),
        _ComplianceCard(percentage: data.attendancePercentage),
      ],
    );
  }

  int _monthWorkMinutes({
    required int presentDays,
    // required int halfDays,
    required int absentDays,
    required double attendanceRate,
  }) {
    final total = presentDays + /* halfDays + */ absentDays;
    if (total == 0) return 0;
    return (total * 540 * attendanceRate / 100).round();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.footnote,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: color),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            footnote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _OvertimeSummary extends StatelessWidget {
  const _OvertimeSummary({required this.deltaMinutes});

  final int deltaMinutes;

  @override
  Widget build(BuildContext context) {
    final isOvertime = deltaMinutes < 0;
    final minutes = deltaMinutes.abs();

    final title = deltaMinutes == 0
        ? 'On Track'
        : isOvertime
        ? 'Overtime'
        : 'Undertime';

    final tone = deltaMinutes == 0
        ? AppColors.textSecondary
        : isOvertime
        ? AppColors.success
        : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: tone,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMinutes(minutes),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tone),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  AppIcons.timer,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (minutes.clamp(0, 600)) / 600,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    final cappedPercentage = percentage.clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: cappedPercentage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  color: Colors.white,
                ),
                Center(
                  child: Text(
                    '${cappedPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Compliance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cappedPercentage >= 90
                      ? 'Excellent attendance'
                      : 'Keep your streak going',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
