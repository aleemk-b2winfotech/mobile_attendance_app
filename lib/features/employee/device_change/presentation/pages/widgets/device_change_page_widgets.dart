part of '../device_change_page.dart';

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final DeviceChangeRequest request;

  @override
  Widget build(BuildContext context) {
    final tone = switch (request.status) {
      'PENDING' => Colors.orange,
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: tone,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(AppIcons.mobile, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'New Device: ${request.requestedDeviceId}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (request.actionNote != null) ...[
              const SizedBox(height: 6),
              Text(
                'Note: ${request.actionNote}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tone,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    final date = DateTime.tryParse(isoString)?.toLocal();
    if (date == null) return isoString;
    return DateFormat('MMM d, yyyy').format(date);
  }
}
