part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _HolidayCard extends StatefulWidget {
  const _HolidayCard({
    required this.row,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  final AdminHoliday row;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  @override
  State<_HolidayCard> createState() => _HolidayCardState();
}

class _HolidayCardState extends State<_HolidayCard> {
  static const double _actionExtent = 188;

  double _dragExtent = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.canManage) return _buildCard(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragExtent = (_dragExtent - details.delta.dx).clamp(
              0.0,
              _actionExtent,
            );
          });
        },
        onHorizontalDragEnd: (_) {
          setState(() {
            _dragExtent = _dragExtent >= _actionExtent / 2 ? _actionExtent : 0;
          });
        },
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Positioned.fill(child: _HolidayActionPane(card: widget)),
            Transform.translate(
              offset: Offset(-_dragExtent, 0),
              child: _buildCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final isDeleted = widget.row.isDeleted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.holiday, color: AppColors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.row.title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (isDeleted)
                const StatusChip(
                  label: 'DELETED',
                  status: 'rejected',
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _holidayDateRange(widget.row.startDate, widget.row.endDate),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.row.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.row.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _HolidayActionPane extends StatelessWidget {
  const _HolidayActionPane({required this.card});

  final _HolidayCard card;

  @override
  Widget build(BuildContext context) {
    final isDeleted = card.row.isDeleted;
    return Container(
      padding: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HolidaySlideAction(
            icon: AppIcons.history,
            label: 'History',
            color: AppColors.infoDark,
            onTap: card.onHistory,
          ),
          _HolidaySlideAction(
            icon: Icons.edit_calendar_rounded,
            label: 'Edit',
            color: AppColors.primaryDark,
            onTap: isDeleted ? null : card.onEdit,
          ),
          _HolidaySlideAction(
            icon: AppIcons.closeCircle,
            label: 'Delete',
            color: AppColors.danger,
            onTap: isDeleted ? null : card.onDelete,
          ),
        ],
      ),
    );
  }
}

class _HolidaySlideAction extends StatelessWidget {
  const _HolidaySlideAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final effectiveColor = enabled ? color : AppColors.textMuted;
    return SizedBox(
      width: 58,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: effectiveColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.rows});

  final List<AdminHolidayHistoryEntry> rows;

  @override
  Widget build(BuildContext context) {
    return SheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Holiday History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const EmptyInfoCard(
              title: 'No history',
              message: 'Changes will appear here.',
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(row.action),
                    subtitle: Text(
                      [
                        row.reason,
                        row.actorName,
                        _formatDateTime(row.createdAt),
                      ].where((value) => value.isNotEmpty).join(' • '),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
