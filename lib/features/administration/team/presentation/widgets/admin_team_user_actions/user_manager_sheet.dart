part of '../admin_team_user_actions.dart';

class _AdminUserManagerSheet extends StatefulWidget {
  const _AdminUserManagerSheet({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserManagerSheet> createState() => _AdminUserManagerSheetState();
}

class _AdminUserManagerSheetState extends State<_AdminUserManagerSheet> {
  final _actions = Get.find<AdminUserActionsController>();
  String? _managerUserId;
  List<AdminUser> _managers = const [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _managerUserId = widget.user.managerUserId;
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    try {
      final managers = await _actions.fetchManagers();
      if (!mounted) return;
      setState(() {
        _managers = managers
            .where(
              (manager) => manager.isActive && manager.id != widget.user.id,
            )
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) return;
      _showSnack(context, _actions.toReadableError(error), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canChange = _actions.canChangeAssignedManager(widget.user);
    final changed =
        _normalizedManagerId(_managerUserId) !=
        _normalizedManagerId(widget.user.managerUserId);

    return SheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change Manager', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(widget.user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Current manager: ${widget.user.managerName ?? 'None'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!canChange)
            Text(
              _actions.currentRole(widget.user) == 'ADMIN'
                  ? 'Admin users do not report to a manager.'
                  : 'Only admins can change reporting manager.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            )
          else if (_loading)
            const LinearProgressIndicator(
              minHeight: 3,
              color: AppColors.primaryDark,
              backgroundColor: AppColors.border,
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _dropdownValue,
              decoration: const InputDecoration(labelText: 'Reporting manager'),
              items: _managerItems,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _managerUserId = value),
            ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: canChange && changed && !_loading && !_saving
                ? _save
                : null,
            child: _saving ? const ButtonSpinner() : const Text('Save Manager'),
          ),
        ],
      ),
    );
  }

  String? get _dropdownValue {
    final current = _normalizedManagerId(_managerUserId);
    if (current == null) return null;
    if (_managers.any((manager) => manager.id == current)) return current;
    return widget.user.managerUserId;
  }

  List<DropdownMenuItem<String>> get _managerItems {
    final currentId = _normalizedManagerId(widget.user.managerUserId);
    final hasCurrent =
        currentId != null &&
        _managers.any((manager) => manager.id == currentId);

    return [
      const DropdownMenuItem<String>(value: null, child: Text('No manager')),
      if (currentId != null && !hasCurrent)
        DropdownMenuItem<String>(
          value: currentId,
          child: Text(widget.user.managerName ?? 'Current manager'),
        ),
      ..._managers.map(
        (manager) => DropdownMenuItem<String>(
          value: manager.id,
          child: Text(manager.fullName),
        ),
      ),
    ];
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await _actions.changeAssignedManager(
        widget.user,
        _normalizedManagerId(_managerUserId),
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

  String? _normalizedManagerId(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
