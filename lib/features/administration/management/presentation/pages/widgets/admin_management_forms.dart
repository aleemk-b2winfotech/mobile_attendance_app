part of '../admin_management_pages.dart';

class _HolidayFormSheet extends StatefulWidget {
  const _HolidayFormSheet({required this.controller, this.holiday});

  final AdminHolidaysController controller;
  final AdminHoliday? holiday;

  @override
  State<_HolidayFormSheet> createState() => _HolidayFormSheetState();
}

class _HolidayFormSheetState extends State<_HolidayFormSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _reason = TextEditingController();
  late String _startDate = (widget.holiday?.startDate ?? '').isEmpty
      ? _today()
      : widget.holiday!.startDate;
  late String _endDate = (widget.holiday?.endDate ?? '').isEmpty
      ? _startDate
      : widget.holiday!.endDate;
  bool _saving = false;

  bool get _editing => widget.holiday != null;

  @override
  void initState() {
    super.initState();
    _title.text = widget.holiday?.title ?? '';
    _description.text = widget.holiday?.description ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _editing ? 'Edit Holiday' : 'Create Holiday',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start',
                  value: _startDate,
                  onChanged: (value) => setState(() => _startDate = value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'End',
                  value: _endDate,
                  onChanged: (value) => setState(() => _endDate = value),
                ),
              ),
            ],
          ),
          if (_editing) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(labelText: 'Change reason'),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const ButtonSpinner()
                : Text(_editing ? 'Save Holiday' : 'Create Holiday'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await widget.controller.saveHoliday(
        holiday: widget.holiday,
        draft: AdminHolidayDraft(
          title: _title.text.trim(),
          description: _description.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          reason: _reason.text.trim(),
        ),
      );
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
}

class _WfhAssignSheet extends StatefulWidget {
  const _WfhAssignSheet({required this.controller});

  final AdminWorkFromHomeController controller;

  @override
  State<_WfhAssignSheet> createState() => _WfhAssignSheetState();
}

class _WfhAssignSheetState extends State<_WfhAssignSheet> {
  List<AdminUser> _users = const [];
  String? _userId;
  List<AdminWfhRangeDraft> _ranges = <AdminWfhRangeDraft>[
    AdminWfhRangeDraft(startDate: _today(), endDate: _today()),
  ];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await widget.controller.fetchAssignableUsers();
      setState(() {
        _users = users;
        _userId = users.isEmpty ? null : users.first.id;
      });
    } catch (_) {
      // The save action will surface API errors if needed.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetPadding(
      child: _loading
          ? const CenteredProgress()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assign WFH',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose an employee and add one or more date ranges.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _userId,
                  decoration: const InputDecoration(labelText: 'Employee'),
                  items: _users
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.fullName),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => setState(() => _userId = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date Ranges',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saving ? null : _addRange,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Range'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._ranges.asMap().entries.map((entry) {
                  final index = entry.key;
                  final range = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _ranges.length - 1 ? 0 : 12,
                    ),
                    child: _WfhRangeCard(
                      index: index,
                      range: range,
                      canRemove: _ranges.length > 1,
                      onStartChanged: (value) =>
                          _updateRange(index, startDate: value),
                      onEndChanged: (value) =>
                          _updateRange(index, endDate: value),
                      onRemove: _saving ? null : () => _removeRange(index),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const ButtonSpinner()
                      : const Text('Assign WFH'),
                ),
              ],
            ),
    );
  }

  Future<void> _save() async {
    final userId = _userId;
    final draft = AdminWfhAssignmentDraft(userId: userId, ranges: _ranges);

    setState(() => _saving = true);
    try {
      final message = await widget.controller.assignWorkFromHome(draft);
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

  void _addRange() {
    setState(() {
      _ranges = <AdminWfhRangeDraft>[
        ..._ranges,
        AdminWfhRangeDraft(startDate: _today(), endDate: _today()),
      ];
    });
  }

  void _removeRange(int index) {
    if (_ranges.length == 1) return;
    setState(() {
      _ranges = <AdminWfhRangeDraft>[
        ..._ranges.take(index),
        ..._ranges.skip(index + 1),
      ];
    });
  }

  void _updateRange(int index, {String? startDate, String? endDate}) {
    setState(() {
      _ranges = _ranges
          .asMap()
          .entries
          .map((entry) {
            if (entry.key != index) return entry.value;
            return entry.value.copyWith(startDate: startDate, endDate: endDate);
          })
          .toList(growable: false);
    });
  }
}

class _WfhRangeCard extends StatelessWidget {
  const _WfhRangeCard({
    required this.index,
    required this.range,
    required this.canRemove,
    required this.onStartChanged,
    required this.onEndChanged,
    this.onRemove,
  });

  final int index;
  final AdminWfhRangeDraft range;
  final bool canRemove;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Range ${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start',
                  value: range.startDate,
                  onChanged: onStartChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'End',
                  value: range.endDate,
                  onChanged: onEndChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
