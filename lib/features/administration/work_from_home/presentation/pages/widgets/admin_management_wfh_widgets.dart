part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _WfhCard extends StatelessWidget {
  const _WfhCard({required this.row, required this.onRemove});

  final AdminWfhRecord row;
  final Future<void> Function(AdminWfhRecord row) onRemove;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      icon: AppIcons.calendarTick,
      title: row.user.fullName,
      subtitle: '${row.user.email}\n${row.attendanceDate}',
      trailing: IconButton(
        onPressed: () => onRemove(row),
        icon: const Icon(AppIcons.close, color: AppColors.danger),
      ),
    );
  }
}
