part of '../dashboard_page.dart';

class _TodaySummaryCard extends StatefulWidget {
  const _TodaySummaryCard({required this.data, this.onOpenHistory});

  final DashboardSnapshot data;
  final VoidCallback? onOpenHistory;

  @override
  State<_TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<_TodaySummaryCard> {
  Timer? _workedTimeTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _TodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  @override
  void dispose() {
    _workedTimeTimer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    if (!_shouldShowLiveWorkedTime(widget.data.today)) {
      _workedTimeTimer?.cancel();
      _workedTimeTimer = null;
      return;
    }

    _now = DateTime.now();
    _workedTimeTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  bool _shouldShowLiveWorkedTime(TodayAttendance status) {
    final punchInAt = status.punchInAt;
    final punchOutAt = status.punchOutAt;
    return status.status == 'working' &&
        punchInAt != null &&
        punchInAt.isNotEmpty &&
        DateTime.tryParse(punchInAt) != null &&
        (punchOutAt == null || punchOutAt.isEmpty);
  }

  String _totalHoursLabel(TodayAttendance status) {
    if (!_shouldShowLiveWorkedTime(status)) {
      return formatMinutes(status.workedMinutes);
    }

    final punchInTime = DateTime.parse(status.punchInAt!).toLocal();
    return formatDurationWithSeconds(_now.difference(punchInTime));
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data.today;
    final chipLabel =
        status.status == 'notPunchedIn' || status.status == 'working'
        ? 'Pending'
        : sentenceCaseStatus(status.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Attendance Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: widget.onOpenHistory,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View History',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 4),
                  Icon(AppIcons.arrowForward, size: 11),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S RECORD",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chipLabel.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    _TodayMetric(
                      label: 'PUNCH IN',
                      value: formatClock(status.punchInAt),
                    ),
                    _TodayMetric(
                      label: 'PUNCH OUT',
                      value: formatClock(status.punchOutAt),
                    ),
                    _TodayMetric(
                      label: 'TOTAL HRS',
                      value: _totalHoursLabel(status),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayMetric extends StatelessWidget {
  const _TodayMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
