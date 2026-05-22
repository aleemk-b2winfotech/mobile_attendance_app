part of '../../../../management/presentation/pages/admin_management_pages.dart';

class _AttendanceRecordCard extends StatefulWidget {
  const _AttendanceRecordCard({required this.record, required this.controller});

  final AdminAttendanceRecord record;
  final AdminAttendanceRecordsController controller;

  @override
  State<_AttendanceRecordCard> createState() => _AttendanceRecordCardState();
}

class _AttendanceRecordCardState extends State<_AttendanceRecordCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final statusKey = record.statusKey;
    final iconTint = statusColor(statusKey);
    final iconSurface = statusSoftColor(statusKey);
    final date = record.date;
    final dateLabel = date.isEmpty ? '-' : formatDate(date);
    final location = record.location;
    final latitude = location?.latitude;
    final longitude = location?.longitude;
    final canOverride = record.canOverride(today: _today());
    final descriptor = _attendanceRecordDescriptor(
      record.attendanceState,
      workedMinutes: record.workedMinutes,
      hasRegularization: record.hasRegularization,
      hasLeave: record.hasLeave,
    );

    return Dismissible(
      key: ValueKey(record.cardKey),
      direction: canOverride
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _openRegularization(context);
        } else {
          setState(() => _expanded = !_expanded);
        }
        return false;
      },
      background: _SwipeActionBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.primaryDark,
        icon: Icons.edit_calendar_rounded,
        label: 'Override',
      ),
      secondaryBackground: _SwipeActionBackground(
        alignment: Alignment.centerRight,
        color: AppColors.infoDark,
        icon: _expanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        label: _expanded ? 'Collapse' : 'Details',
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.cardDecoration(
          borderColor: const Color(0x0D1D3C8B),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(statusIcon(statusKey), size: 17, color: iconTint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateLabel • ${descriptor.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusSoftColor(statusKey),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sentenceCaseStatus(statusKey),
                    style: TextStyle(
                      color: statusColor(statusKey),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (record.hasRegularization) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _AttendanceContextChip(
                      label: record.hasLeave
                          ? 'Leave overridden'
                          : 'Overridden',
                      color: AppColors.primaryDark,
                      backgroundColor: const Color(0xFFE0E7FF),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x0D1D3C8B))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AttendanceMetricBlock(
                    label: 'CHECK IN',
                    value: _time(record.punchInAt),
                  ),
                  _AttendanceMetricBlock(
                    label: 'CHECK OUT',
                    value: _time(record.punchOutAt),
                  ),
                  _AttendanceMetricBlock(
                    label: 'DURATION',
                    value: _formatMinutes(record.workedMinutes),
                    valueColor: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: _AttendanceExpandedDetails(
                email: record.user.email,
                workMode: record.workMode,
                todayPlan: record.todayPlan,
                report: record.report,
                reason: record.regularizationReason,
                latitude: latitude,
                longitude: longitude,
                onOpenMap: latitude == null || longitude == null
                    ? null
                    : () => _openLocationInMaps(
                        context,
                        latitude: latitude,
                        longitude: longitude,
                      ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOut,
              sizeCurve: Curves.easeOut,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRegularization(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RegularizationSheet(
        controller: widget.controller,
        record: widget.record,
      ),
    );
  }

  Future<void> _openLocationInMaps(
    BuildContext context, {
    required double latitude,
    required double longitude,
  }) async {
    final message = await widget.controller.openLocationInMaps(
      latitude: latitude,
      longitude: longitude,
    );
    if (message == null || !context.mounted) return;
    _showSnack(context, message, isError: true);
  }
}

class _AttendanceMetricBlock extends StatelessWidget {
  const _AttendanceMetricBlock({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _AttendanceExpandedDetails extends StatelessWidget {
  const _AttendanceExpandedDetails({
    required this.email,
    required this.workMode,
    required this.todayPlan,
    required this.report,
    required this.reason,
    required this.latitude,
    required this.longitude,
    required this.onOpenMap,
  });

  final String email;
  final String workMode;
  final String todayPlan;
  final String report;
  final String reason;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final notes = <String>[
      todayPlan,
      report,
      reason,
    ].where((value) => value.isNotEmpty).toList(growable: false);
    final hasCoordinates = latitude != null && longitude != null;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x0D1D3C8B))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (email.isNotEmpty) _MiniInfo(label: 'Email', value: email),
                if (workMode.isNotEmpty)
                  _MiniInfo(label: 'Mode', value: workMode),
                if (hasCoordinates)
                  _MiniInfo(
                    label: 'GPS',
                    value:
                        '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                  ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                notes.join('\n'),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (hasCoordinates) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(AppIcons.location, size: 16),
                  label: const Text('Map'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: color,
        padding: EdgeInsets.only(left: isLeft ? 18 : 0, right: isLeft ? 0 : 18),
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isLeft) Text(label, style: _style),
            if (!isLeft) const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 20),
            if (isLeft) const SizedBox(width: 8),
            if (isLeft) Text(label, style: _style),
          ],
        ),
      ),
    );
  }

  static const _style = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}

class _RegularizationSheet extends StatefulWidget {
  const _RegularizationSheet({required this.controller, required this.record});

  final AdminAttendanceRecordsController controller;
  final AdminAttendanceRecord record;

  @override
  State<_RegularizationSheet> createState() => _RegularizationSheetState();
}

class _RegularizationSheetState extends State<_RegularizationSheet> {
  final _reason = TextEditingController();
  String _status = 'PRESENT';
  TimeOfDay? _punchIn;
  TimeOfDay? _punchOut;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.record.regularizationOverrideStatus;
    _punchIn = _timeOfDayFromValue(widget.record.punchInAt);
    _punchOut = _timeOfDayFromValue(widget.record.punchOutAt);
    _reason.text = widget.record.regularizationReason;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requiresPunchTimes = _requiresPunchTimes(_status);
    return SheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Attendance Override',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'PRESENT', child: Text('Present')),
              DropdownMenuItem(value: 'HALF_DAY', child: Text('Half day')),
              DropdownMenuItem(value: 'ABSENT', child: Text('Absent')),
              DropdownMenuItem(value: 'ON_LEAVE', child: Text('Leave')),
            ],
            onChanged: (value) => setState(() => _status = value ?? _status),
          ),
          if (requiresPunchTimes) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RegularizationTimeField(
                    label: 'Punch In',
                    value: _formatTimeOfDay(_punchIn),
                    onTap: () => _pickTime(isPunchIn: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RegularizationTimeField(
                    label: 'Punch Out',
                    value: _formatTimeOfDay(_punchOut),
                    onTap: () => _pickTime(isPunchIn: false),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const ButtonSpinner()
                : const Text('Save Override'),
          ),
          if (_hasRegularization) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _saving ? null : _delete,
              child: const Text('Remove Override'),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasRegularization {
    return widget.record.hasRegularization;
  }

  Future<void> _pickTime({required bool isPunchIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isPunchIn ? _punchIn : _punchOut) ??
          (isPunchIn ? const TimeOfDay(hour: 9, minute: 0) : _defaultPunchOut),
    );
    if (!mounted || picked == null) return;

    setState(() {
      if (isPunchIn) {
        _punchIn = picked;
      } else {
        _punchOut = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await widget.controller.upsertRegularization(_draft());
      if (!mounted) return;
      if (message != null) {
        _showSnack(context, message, isError: true);
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      final message = await widget.controller.deleteRegularization(_draft());
      if (!mounted) return;
      if (message != null) {
        _showSnack(context, message, isError: true);
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  AdminAttendanceOverrideDraft _draft() {
    final requiresPunchTimes = _requiresPunchTimes(_status);
    return AdminAttendanceOverrideDraft(
      userId: widget.record.user.id,
      date: widget.record.date,
      status: AdminAttendanceOverrideStatus.fromValue(_status),
      reason: _reason.text.trim(),
      overridePunchInAt: requiresPunchTimes
          ? _overrideDateTime(_punchIn)
          : null,
      overridePunchOutAt: requiresPunchTimes
          ? _overrideDateTime(_punchOut)
          : null,
    );
  }

  bool _requiresPunchTimes(String status) {
    return status != 'ABSENT' && status != 'ON_LEAVE';
  }

  String? _overrideDateTime(TimeOfDay? time) {
    if (time == null) return null;

    final date = DateTime.tryParse(widget.record.date);
    if (date == null) return null;

    final localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return localDateTime.toUtc().toIso8601String();
  }

  TimeOfDay? _timeOfDayFromValue(Object? value) {
    final dateTime = DateTime.tryParse(_text(value));
    if (dateTime == null) return null;

    final local = dateTime.toLocal();
    return TimeOfDay(hour: local.hour, minute: local.minute);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select';

    return DateFormat(
      'hh:mm a',
    ).format(DateTime(2000, 1, 1, time.hour, time.minute));
  }

  TimeOfDay get _defaultPunchOut {
    final punchIn = _punchIn;
    if (punchIn == null) return const TimeOfDay(hour: 18, minute: 0);

    final minutes = punchIn.hour * 60 + punchIn.minute + 9 * 60;
    return TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);
  }
}

class _RegularizationTimeField extends StatelessWidget {
  const _RegularizationTimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(AppIcons.clock, size: 18),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AttendanceContextChip extends StatelessWidget {
  const _AttendanceContextChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _attendanceRecordDescriptor(
  String state, {
  required int workedMinutes,
  required bool hasRegularization,
  required bool hasLeave,
}) {
  if (hasRegularization && hasLeave) return 'Leave overridden';
  if (hasRegularization) return 'Overridden';
  return attendanceDescriptor(state, workedMinutes: workedMinutes);
}
