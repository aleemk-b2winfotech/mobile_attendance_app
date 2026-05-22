part of '../dashboard_page.dart';

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
      children: [
        Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 126,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner({required this.data});

  final DashboardSnapshot data;

  @override
  Widget build(BuildContext context) {
    final name = data.user?.fullName ?? 'Team Member';
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final dateLabel = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greetingLabel()}, $firstName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          dateLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _greetingLabel() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _PunchActionCard extends StatelessWidget {
  const _PunchActionCard({
    required this.status,
    required this.isBusy,
    required this.onTap,
  });

  final TodayAttendance status;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPunchOut = status.status == 'working';
    final locked = <String>{
      'holiday',
      'weeklyOff',
      'onLeave',
      'completed',
    }.contains(status.status);

    final enabled = !isBusy && !locked;

    final background = isPunchOut
        ? AppColors.danger
        : locked
        ? AppColors.primary
        : AppColors.success;

    final icon = isBusy
        ? null
        : locked
        ? AppIcons.lock
        : isPunchOut
        ? AppIcons.logout
        : AppIcons.touch;

    final title = isPunchOut
        ? 'Punch Out'
        : locked
        ? sentenceCaseStatus(status.status)
        : 'Punch In';

    final subtitle = status.status == 'holiday' ? status.holiday : null;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: isBusy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
