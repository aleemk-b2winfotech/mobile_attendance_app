part of '../leaves_page.dart';

class _HolidaysTab extends StatelessWidget {
  const _HolidaysTab({
    required this.holidays,
    required this.selectedFilter,
    required this.isLoading,
    required this.onFilterChanged,
    required this.onRefresh,
    this.errorText,
  });

  final List<HolidayItem> holidays;
  final HolidayFilter selectedFilter;
  final bool isLoading;
  final String? errorText;
  final ValueChanged<HolidayFilter> onFilterChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (errorText != null && holidays.isEmpty && !isLoading) {
      return CenterErrorView(message: errorText!, onRetry: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        children: [
          Text(
            _holidayFilterTitle(selectedFilter),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            holidays.isEmpty
                ? _holidayFilterSubtitle(selectedFilter)
                : '${holidays.length} company holiday${holidays.length == 1 ? '' : 's'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _HolidayFilterStrip(
            selectedFilter: selectedFilter,
            isLoading: isLoading,
            onChanged: onFilterChanged,
          ),
          const SizedBox(height: 16),
          if (isLoading && holidays.isEmpty)
            const _HolidaySkeletonList()
          else if (holidays.isEmpty)
            EmptyInfoCard(
              title: 'No Holidays',
              message: _holidayFilterEmptyMessage(selectedFilter),
              icon: AppIcons.holiday,
            )
          else ...[
            if (isLoading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  color: AppColors.primaryDark,
                  backgroundColor: AppColors.border,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...holidays.map(
              (holiday) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HolidayListTile(item: holiday),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _holidayFilterTitle(HolidayFilter filter) {
    return switch (filter) {
      HolidayFilter.all => 'All Holidays',
      HolidayFilter.upcoming => 'Upcoming Holidays',
      HolidayFilter.past => 'Past Holidays',
    };
  }

  String _holidayFilterEmptyMessage(HolidayFilter filter) {
    return switch (filter) {
      HolidayFilter.all => 'No holidays are available right now.',
      HolidayFilter.upcoming => 'No upcoming holidays found.',
      HolidayFilter.past => 'No past holidays found.',
    };
  }

  String _holidayFilterSubtitle(HolidayFilter filter) {
    return switch (filter) {
      HolidayFilter.all => 'Company holidays will appear here.',
      HolidayFilter.upcoming => 'Upcoming company holidays will appear here.',
      HolidayFilter.past => 'Past company holidays will appear here.',
    };
  }
}

class _HolidayFilterStrip extends StatelessWidget {
  const _HolidayFilterStrip({
    required this.selectedFilter,
    required this.onChanged,
    this.isLoading = false,
  });

  final HolidayFilter selectedFilter;
  final ValueChanged<HolidayFilter> onChanged;
  final bool isLoading;

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
                selected: selectedFilter == HolidayFilter.all,
                onTap: () => onChanged(HolidayFilter.all),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Upcoming',
                icon: AppIcons.calendarTick,
                color: AppColors.primary,
                selected: selectedFilter == HolidayFilter.upcoming,
                onTap: () => onChanged(HolidayFilter.upcoming),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Past',
                icon: AppIcons.history,
                color: AppColors.textSecondary,
                selected: selectedFilter == HolidayFilter.past,
                onTap: () => onChanged(HolidayFilter.past),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HolidayListTile extends StatelessWidget {
  const _HolidayListTile({required this.item});

  final HolidayItem item;

  @override
  Widget build(BuildContext context) {
    final days = _holidayDayCount(item);
    final description = item.description?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(
        radius: BorderRadius.circular(18),
        borderColor: const Color(0x0D1D3C8B),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatDate(item.startDate, pattern: 'MMM').toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  formatDate(item.startDate, pattern: 'dd'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  _holidayRange(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: statusSoftColor('holiday'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$days ${days == 1 ? 'day' : 'days'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor('holiday'),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _holidayDayCount(HolidayItem holiday) {
    final start = DateTime.tryParse(holiday.startDate);
    final end = DateTime.tryParse(holiday.endDate);
    if (start == null || end == null || end.isBefore(start)) return 1;
    return end.difference(start).inDays + 1;
  }

  String _holidayRange(HolidayItem holiday) {
    if (holiday.startDate == holiday.endDate) {
      return formatDate(holiday.startDate, pattern: 'EEEE, MMM d');
    }

    return '${formatDate(holiday.startDate, pattern: 'MMM d')} - '
        '${formatDate(holiday.endDate, pattern: 'MMM d, yyyy')}';
  }
}

class _HolidaySkeletonList extends StatelessWidget {
  const _HolidaySkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 86,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x0D1D3C8B)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        width: 112,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
