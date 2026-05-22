part of '../admin_home_shell.dart';

class _ManagementModulesSection extends StatelessWidget {
  const _ManagementModulesSection();

  @override
  Widget build(BuildContext context) {
    final modules = <_ModuleSpec>[
      _ModuleSpec(
        title: 'Attendance',
        subtitle: 'Review and regularize records',
        icon: AppIcons.history,
        page: const AdminAttendanceRecordsPage(),
      ),
      _ModuleSpec(
        title: 'Analytics',
        subtitle: 'Team attendance rollups',
        icon: AppIcons.trendUp,
        page: const AdminAnalyticsPage(),
      ),
      _ModuleSpec(
        title: 'Holidays',
        subtitle: 'Calendar and audit history',
        icon: AppIcons.holiday,
        page: const AdminHolidaysPage(),
      ),
      _ModuleSpec(
        title: 'Work From Home',
        subtitle: 'Assign and remove WFH days',
        icon: AppIcons.calendarTick,
        page: const AdminWorkFromHomePage(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Text(
            'Management',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...modules.asMap().entries.map((entry) {
          final index = entry.key;
          final module = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < modules.length - 1 ? 12 : 0,
            ),
            child: _ModuleTile(module: module),
          );
        }),
      ],
    );
  }
}

class _ModuleSpec {
  const _ModuleSpec({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final _ModuleSpec module;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      icon: module.icon,
      title: module.title,
      subtitle: module.subtitle,
      trailing: const Icon(AppIcons.arrowForward, size: 18),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (context) => module.page));
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}
