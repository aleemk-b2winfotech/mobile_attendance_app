part of '../admin_team_user_actions.dart';

class _AdminCreateUserSheet extends StatefulWidget {
  const _AdminCreateUserSheet();

  @override
  State<_AdminCreateUserSheet> createState() => _AdminCreateUserSheetState();
}

class _AdminCreateUserSheetState extends State<_AdminCreateUserSheet> {
  final _actions = Get.find<AdminUserActionsController>();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String _role = 'EMPLOYEE';
  String? _managerUserId;
  List<AdminUser> _managers = const [];
  bool _loadingManagers = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (_actions.isAdminCaller) {
      _loadManagers();
    } else {
      _loadingManagers = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _loadManagers() async {
    try {
      final managers = await _actions.fetchManagers();
      if (!mounted) return;
      setState(() {
        _managers = managers;
      });
    } catch (_) {
      // Manager selection is optional; create will surface API errors if needed.
    } finally {
      if (mounted) {
        setState(() => _loadingManagers = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSelectManager = _actions.canSelectManagerForRole(_role);
    return SheetPadding(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create User', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              _actions.isAdminCaller
                  ? 'Add a team member and choose their reporting manager.'
                  : 'Add a team member under your reporting hierarchy.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: _actions.createRoleOptions
                  .map(
                    (role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(_actions.roleLabel(role)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _saving
                  ? null
                  : (value) => setState(() {
                      _role = value ?? _role;
                      if (!_actions.canSelectManagerForRole(_role)) {
                        _managerUserId = null;
                      }
                    }),
            ),
            if (canSelectManager) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _managerUserId,
                decoration: const InputDecoration(labelText: 'Manager'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No manager'),
                  ),
                  ..._managers
                      .where((manager) => manager.isActive)
                      .map(
                        (manager) => DropdownMenuItem<String>(
                          value: manager.id,
                          child: Text(manager.fullName),
                        ),
                      ),
                ],
                onChanged: _saving || _loadingManagers
                    ? null
                    : (value) => setState(() => _managerUserId = value),
              ),
            ],
            if (_loadingManagers) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primaryDark,
                backgroundColor: AppColors.border,
              ),
            ],
            if (!_actions.isAdminCaller) ...[
              const SizedBox(height: 12),
              Text(
                'New users will report directly to you.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const ButtonSpinner()
                  : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final message = await _actions.createUser(
        AdminUserDraft(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          role: _role,
          managerUserId: _managerUserId,
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
