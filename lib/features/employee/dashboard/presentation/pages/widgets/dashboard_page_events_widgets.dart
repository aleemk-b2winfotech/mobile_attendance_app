part of '../dashboard_page.dart';

class _UpcomingWfhDays extends StatelessWidget {
  const _UpcomingWfhDays({required this.dates});

  final List<String> dates;

  @override
  Widget build(BuildContext context) {
    final rows = dates.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming WFH Days',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 2),
        Text(
          'Your next ${rows.length} work-from-home day${rows.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (date) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WfhTile(date: date),
          ),
        ),
      ],
    );
  }
}

class _WfhTile extends StatelessWidget {
  const _WfhTile({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        background: AppColors.surfaceSoft,
        radius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(date, pattern: 'dd'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 30,
                    color: const Color(0xFF475569),
                  ),
                ),
                Text(
                  formatDate(date, pattern: 'EEEE').toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: AppColors.textSecondary.withValues(alpha: 0.24),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Text(
              formatDate(date, pattern: 'MMMM').toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
