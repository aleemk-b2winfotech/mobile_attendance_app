part of '../admin_management_pages.dart';

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: ${value.isEmpty ? '-' : value}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _TinyStat extends StatelessWidget {
  const _TinyStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({required this.meta, required this.onPage});

  final AdminPaginationMeta meta;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final page = meta.page;
    final totalPages = meta.totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: page <= 1 ? null : () => onPage(page - 1),
            icon: const Icon(AppIcons.arrowBack, size: 14),
            label: const Text('Previous'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$page / $totalPages'),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: page >= totalPages ? null : () => onPage(page + 1),
            icon: const Icon(AppIcons.arrowForward, size: 14),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

T _adminController<T extends GetxController>() => Get.find<T>();

String _text(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}
