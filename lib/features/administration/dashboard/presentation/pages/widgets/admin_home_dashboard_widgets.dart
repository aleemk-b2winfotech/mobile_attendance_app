part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _AdminWelcomeCard extends GetView<AuthController> {
  const _AdminWelcomeCard({required this.snapshot});

  final AdminDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final name = controller.user.value?.fullName ?? 'Administrator';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        background: AppColors.primaryDark,
        borderColor: AppColors.primaryDark,
        radius: BorderRadius.circular(18),
        shadows: const [
          BoxShadow(
            color: Color(0x261D3C8B),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.lock, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          Text(
            'Welcome, $name',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '${snapshot.headcount} active employees under your scope',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.snapshot});

  final AdminDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final attendance = snapshot.attendance;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.36,
      children: [
        _StatCard(
          icon: AppIcons.people,
          label: 'Headcount',
          value: snapshot.headcount.toString(),
          color: AppColors.info,
        ),
        _StatCard(
          icon: AppIcons.trendUp,
          label: 'Attendance',
          value: '${attendance.attendancePercentage.toStringAsFixed(1)}%',
          color: AppColors.success,
        ),
        _StatCard(
          icon: AppIcons.present,
          label: 'Present days',
          value: attendance.presentDays.toString(),
          color: AppColors.primary,
        ),
        _StatCard(
          icon: AppIcons.absent,
          label: 'Absent days',
          value: attendance.absentDays.toString(),
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.snapshot, required this.onOpen});

  final AdminDashboardSnapshot snapshot;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final total =
        snapshot.pendingLeaveCount + snapshot.pendingDeviceChangeCount;
    final summary =
        '$total total • ${snapshot.pendingLeaveCount} leave • '
        '${snapshot.pendingDeviceChangeCount} device';
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                AppIcons.pending,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pending approvals',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              AppIcons.arrowForward,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
