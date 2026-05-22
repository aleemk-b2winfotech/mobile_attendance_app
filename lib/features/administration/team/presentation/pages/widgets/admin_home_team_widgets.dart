part of '../../../../shell/presentation/pages/admin_home_shell.dart';

class _UserTile extends StatefulWidget {
  const _UserTile({
    super.key,
    required this.user,
    required this.index,
    required this.onChanged,
  });

  final AdminUser user;
  final int index;
  final Future<void> Function() onChanged;

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  static const double _swipeThreshold = 36;
  static const double _swipeVelocityThreshold = 350;

  double _dragDeltaX = 0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final animationSteps = widget.index < 6 ? widget.index : 6;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (animationSteps * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onHorizontalDragStart: (_) => _dragDeltaX = 0,
        onHorizontalDragUpdate: (details) {
          _dragDeltaX += details.delta.dx;
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          final shouldToggle =
              velocity.abs() > _swipeVelocityThreshold ||
              _dragDeltaX.abs() > _swipeThreshold;
          if (!shouldToggle) return;
          setState(() => _expanded = !_expanded);
        },
        onHorizontalDragCancel: () => _dragDeltaX = 0,
        child: _UserCard(
          user: widget.user,
          expanded: _expanded,
          onAction: _handleAction,
        ),
      ),
    );
  }

  Future<void> _handleAction(_UserTileAction action) async {
    if (_expanded) setState(() => _expanded = false);
    final actionFuture = switch (action) {
      _UserTileAction.name => showAdminUserNameEditDialog(
        context,
        user: widget.user,
      ),
      _UserTileAction.promote => showAdminUserRolePromotionDialog(
        context,
        user: widget.user,
      ),
      _UserTileAction.manager => showAdminUserManagerSheet(
        context,
        user: widget.user,
      ),
      _UserTileAction.location => showAdminUserLocationSheet(
        context,
        user: widget.user,
      ),
      _UserTileAction.deviceLogs => showAdminUserDeviceLogsSheet(
        context,
        user: widget.user,
      ),
      _UserTileAction.activate => showAdminUserActivateDialog(
        context,
        user: widget.user,
      ),
      _UserTileAction.deactivate => showAdminUserDeactivateDialog(
        context,
        user: widget.user,
      ),
    };
    final changed = await actionFuture;

    if (!mounted || !changed) return;

    await widget.onChanged();
    if (!mounted) return;

    final message = switch (action) {
      _UserTileAction.name => 'Name updated.',
      _UserTileAction.promote => 'Role promoted.',
      _UserTileAction.manager => 'Reporting manager updated.',
      _UserTileAction.location => 'Location updated.',
      _UserTileAction.deviceLogs => '',
      _UserTileAction.activate => 'User activated.',
      _UserTileAction.deactivate => 'User deactivated.',
    };

    if (message.isNotEmpty) AppToast.success(message);
  }
}

enum _UserTileAction {
  name,
  promote,
  manager,
  location,
  deviceLogs,
  activate,
  deactivate,
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.expanded,
    required this.onAction,
  });

  final AdminUser user;
  final bool expanded;
  final void Function(_UserTileAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final role = user.roles.isEmpty ? 'EMPLOYEE' : user.roles.join(', ');
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration(radius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.fullName.isEmpty
                        ? '?'
                        : user.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (user.managerName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Manager: ${user.managerName}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusChip(
                      label: user.isActive ? role : 'INACTIVE',
                      status: user.isActive ? role : 'rejected',
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.swap_horiz_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              _UserActionRow(user: user, onAction: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserActionRow extends StatelessWidget {
  const _UserActionRow({required this.user, required this.onAction});

  final AdminUser user;
  final void Function(_UserTileAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final actionsController = Get.find<AdminUserActionsController>();
    final actions = <_UserActionSpec>[
      if (actionsController.canEditName(user))
        _UserActionSpec(
          action: _UserTileAction.name,
          color: AppColors.infoDark,
          icon: Icons.drive_file_rename_outline_rounded,
          label: 'Name',
        ),
      if (actionsController.canPromoteRole(user))
        _UserActionSpec(
          action: _UserTileAction.promote,
          color: AppColors.successDark,
          icon: Icons.trending_up_rounded,
          label: 'Promote',
        ),
      if (actionsController.canChangeAssignedManager(user))
        _UserActionSpec(
          action: _UserTileAction.manager,
          color: AppColors.infoDark,
          icon: Icons.manage_accounts_rounded,
          label: 'Manager',
        ),
      _UserActionSpec(
        action: _UserTileAction.location,
        color: AppColors.primaryDark,
        icon: AppIcons.location,
        label: 'Location',
      ),
      _UserActionSpec(
        action: _UserTileAction.deviceLogs,
        color: AppColors.warningDark,
        icon: Icons.phonelink_setup_rounded,
        label: 'Devices',
      ),
      if (actionsController.canActivateUser(user))
        _UserActionSpec(
          action: _UserTileAction.activate,
          color: AppColors.successDark,
          icon: Icons.person_add_alt_1_rounded,
          label: 'Activate',
        ),
      if (actionsController.canDeactivateUser(user))
        _UserActionSpec(
          action: _UserTileAction.deactivate,
          color: AppColors.dangerDark,
          icon: Icons.person_off_outlined,
          label: 'Deactivate',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = actions.length <= 2 ? actions.length : 3;
        final itemWidth =
            (constraints.maxWidth - (8 * (columns - 1))) / columns;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final spec in actions)
              SizedBox(
                width: itemWidth,
                child: _CardActionButton(
                  spec: spec,
                  onTap: () => onAction(spec.action),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UserActionSpec {
  const _UserActionSpec({
    required this.action,
    required this.color,
    required this.icon,
    required this.label,
  });

  final _UserTileAction action;
  final Color color;
  final IconData icon;
  final String label;
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({required this.spec, required this.onTap});

  final _UserActionSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: spec.color.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(spec.icon, color: spec.color, size: 19),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  spec.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: spec.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
