part of '../admin_home_shell.dart';

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.name,
    required this.email,
    required this.roles,
    required this.isActive,
  });

  final String name;
  final String email;
  final List<String> roles;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryDark,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...roles.map(
                (role) => StatusChip(label: role, status: role, compact: true),
              ),
              StatusChip(
                label: isActive ? 'ACTIVE' : 'INACTIVE',
                status: isActive ? 'approved' : 'rejected',
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
