part of '../admin_team_user_actions.dart';

class _AdminUserNameDialog extends StatefulWidget {
  const _AdminUserNameDialog({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserNameDialog> createState() => _AdminUserNameDialogState();
}

class _AdminUserNameDialogState extends State<_AdminUserNameDialog> {
  final _actions = Get.find<AdminUserActionsController>();
  late final TextEditingController _name = TextEditingController(
    text: widget.user.fullName,
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_actions.canEditName(widget.user)) {
      return AlertDialog(
        title: const Text('Activate User First'),
        content: Text('Activate ${widget.user.fullName} before editing name.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _name,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'New name'),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const ButtonSpinner() : const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await _actions.updateName(widget.user, _name.text);
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

class _AdminUserRolePromotionDialog extends StatefulWidget {
  const _AdminUserRolePromotionDialog({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserRolePromotionDialog> createState() =>
      _AdminUserRolePromotionDialogState();
}

class _AdminUserRolePromotionDialogState
    extends State<_AdminUserRolePromotionDialog> {
  final _actions = Get.find<AdminUserActionsController>();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final currentRole = _actions.currentRole(widget.user);
    final nextRole = _actions.nextPromotedRole(widget.user);

    if (!widget.user.isActive) {
      return AlertDialog(
        title: const Text('Activate User First'),
        content: Text('Activate ${widget.user.fullName} before changing role.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    if (nextRole == null) {
      return AlertDialog(
        title: const Text('Role already promoted'),
        content: Text(
          '${widget.user.fullName} is already ${_actions.roleLabel(currentRole)}.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Promote Role?'),
      content: Text(
        'Promote ${widget.user.fullName} from '
        '${_actions.roleLabel(currentRole)} to ${_actions.roleLabel(nextRole)}?',
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const ButtonSpinner() : const Text('Promote'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await _actions.promoteRole(widget.user);
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

class _AdminUserActivateDialog extends StatefulWidget {
  const _AdminUserActivateDialog({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserActivateDialog> createState() =>
      _AdminUserActivateDialogState();
}

class _AdminUserActivateDialogState extends State<_AdminUserActivateDialog> {
  final _actions = Get.find<AdminUserActionsController>();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.user.isActive) {
      return AlertDialog(
        title: const Text('User already active'),
        content: Text('${widget.user.fullName} is already active.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    if (!_actions.canActivateUser(widget.user)) {
      return AlertDialog(
        title: const Text('Cannot Activate User'),
        content: const Text('You cannot activate this user.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Activate User?'),
      content: Text(
        'Activate ${widget.user.fullName}? They will be able to sign in again '
        'with a new session.',
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const ButtonSpinner() : const Text('Activate'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await _actions.activateUser(widget.user);
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

class _AdminUserDeactivateDialog extends StatefulWidget {
  const _AdminUserDeactivateDialog({required this.user});

  final AdminUser user;

  @override
  State<_AdminUserDeactivateDialog> createState() =>
      _AdminUserDeactivateDialogState();
}

class _AdminUserDeactivateDialogState
    extends State<_AdminUserDeactivateDialog> {
  final _actions = Get.find<AdminUserActionsController>();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.user.isActive) {
      return AlertDialog(
        title: const Text('User already inactive'),
        content: Text('${widget.user.fullName} is already inactive.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    if (!_actions.canDeactivateUser(widget.user)) {
      return AlertDialog(
        title: const Text('Cannot Deactivate User'),
        content: const Text('You cannot deactivate this user.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Deactivate User?'),
      content: Text(
        'Deactivate ${widget.user.fullName}? They will no longer be able to '
        'sign in and active sessions will be revoked.',
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.dangerDark,
            foregroundColor: Colors.white,
          ),
          onPressed: _saving ? null : _save,
          child: _saving ? const ButtonSpinner() : const Text('Deactivate'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final message = await _actions.deactivateUser(widget.user);
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
