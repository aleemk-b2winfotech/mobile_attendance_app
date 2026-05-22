part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _AnalyticsSummaryRevealHeader extends StatelessWidget {
  const _AnalyticsSummaryRevealHeader({
    required this.aggregate,
    required this.pullExtent,
    required this.threshold,
    required this.isShowing,
    required this.onHide,
  });

  final AdminAnalyticsAggregate aggregate;
  final double pullExtent;
  final double threshold;
  final bool isShowing;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    if (isShowing) {
      return Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: onHide,
              icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
              label: const Text('Hide summary'),
            ),
          ),
          _AnalyticsSummary(aggregate: aggregate),
        ],
      );
    }

    if (pullExtent <= 0) return const SizedBox.shrink();

    final progress = (pullExtent / threshold).clamp(0.0, 1.0);
    final previewHeight = 230.0 * progress;
    return ClipRect(
      child: SizedBox(
        height: previewHeight,
        child: Align(
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: 0.35 + (0.65 * progress),
            child: _AnalyticsSummary(aggregate: aggregate),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({required this.aggregate});

  final AdminAnalyticsAggregate aggregate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: [
          _TinyStat(
            label: 'Attendance',
            value: '${aggregate.attendancePercentage.toStringAsFixed(1)}%',
            icon: AppIcons.trendUp,
          ),
          _TinyStat(
            label: 'Half days',
            value: aggregate.halfDays.toString(),
            icon: AppIcons.halfDay,
          ),
          _TinyStat(
            label: 'Present',
            value: aggregate.presentDays.toString(),
            icon: AppIcons.present,
          ),
          _TinyStat(
            label: 'Absent',
            value: aggregate.absentDays.toString(),
            icon: AppIcons.absent,
          ),
        ],
      ),
    );
  }
}

class _AnalyticsUserCard extends StatelessWidget {
  const _AnalyticsUserCard({required this.row});

  final AdminAnalyticsRow row;

  @override
  Widget build(BuildContext context) {
    final percent = row.summary.attendancePercentage;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.user.fullName,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 2),
          Text(row.user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: percent >= 80
                  ? AppColors.success
                  : percent >= 50
                  ? AppColors.warning
                  : AppColors.danger,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniInfo(
                label: 'Attendance',
                value: '${percent.toStringAsFixed(1)}%',
              ),
              _MiniInfo(
                label: 'Present',
                value: row.summary.presentDays.toString(),
              ),
              _MiniInfo(label: 'Half', value: row.summary.halfDays.toString()),
              _MiniInfo(
                label: 'Absent',
                value: row.summary.absentDays.toString(),
              ),
              _MiniInfo(
                label: 'Hours',
                value: _formatMinutes(row.summary.totalWorkedMinutes),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
