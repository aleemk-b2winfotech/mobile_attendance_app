import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/widgets/app_bottom_navigation.dart';
import 'package:app/core/widgets/app_header.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/core/widgets/centered_progress.dart';
import 'package:app/core/widgets/state_views.dart';
import 'package:app/core/widgets/status_chip.dart';
import 'package:app/features/administration/approvals/domain/models/admin_approval_models.dart';
import 'package:app/features/administration/dashboard/domain/models/admin_dashboard_models.dart';
import 'package:app/features/administration/dashboard/presentation/controllers/admin_dashboard_controller.dart';
import 'package:app/features/administration/management/presentation/pages/admin_management_pages.dart';
import 'package:app/features/administration/shell/presentation/controllers/admin_home_controller.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/administration/team/presentation/controllers/admin_user_actions_controller.dart';
import 'package:app/features/administration/team/presentation/widgets/admin_team_user_actions.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

part '../../../approvals/presentation/pages/widgets/admin_home_approval_tabs.dart';
part '../../../approvals/presentation/pages/widgets/admin_home_approval_tile.dart';
part '../../../approvals/presentation/pages/widgets/admin_home_leave_thread_page.dart';
part '../../../approvals/presentation/pages/widgets/admin_home_leave_thread_widgets.dart';
part '../../../dashboard/presentation/pages/widgets/admin_home_dashboard_widgets.dart';
part '../../../team/presentation/pages/widgets/admin_home_team_widgets.dart';
part 'widgets/admin_home_profile_widgets.dart';
part 'widgets/admin_home_management_widgets.dart';

class AdminHomeShell extends StatelessWidget {
  const AdminHomeShell({super.key});

  static const _adminNavigationItems = <AppBottomNavigationItem>[
    AppBottomNavigationItem('Dashboard', Icons.dashboard_rounded),
    AppBottomNavigationItem('Team', AppIcons.people),
    AppBottomNavigationItem('Approvals', Icons.fact_check_rounded),
    AppBottomNavigationItem('Profile', Icons.admin_panel_settings_rounded),
  ];

  AdminHomeController _ensureController() {
    return Get.find<AdminHomeController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ensureController();
    final pages = <Widget>[
      AdminDashboardPage(onOpenApprovals: () => controller.switchTab(2)),
      const AdminTeamPage(),
      const AdminApprovalsPage(),
      const AdminProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Obx(
        () =>
            IndexedStack(index: controller.selectedTab.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavigation(
          currentIndex: controller.selectedTab.value,
          onChanged: controller.switchTab,
          items: _adminNavigationItems,
        ),
      ),
    );
  }
}

class AdminDashboardPage extends GetView<AdminDashboardController> {
  const AdminDashboardPage({super.key, required this.onOpenApprovals});

  final VoidCallback onOpenApprovals;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(() {
        final snapshot = controller.dashboard.value;

        if (controller.isLoading.value && snapshot == null) {
          return const CenteredProgress();
        }

        if (controller.errorText.value != null && snapshot == null) {
          return CenterErrorView(
            message: controller.errorText.value!,
            onRetry: controller.refreshData,
          );
        }

        if (snapshot == null) return const CenteredProgress();
        final hasPendingApprovals =
            snapshot.pendingLeaveCount > 0 ||
            snapshot.pendingDeviceChangeCount > 0;

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              _AdminWelcomeCard(snapshot: snapshot),
              const SizedBox(height: 18),
              _StatGrid(snapshot: snapshot),
              if (hasPendingApprovals) ...[
                const SizedBox(height: 18),
                _PendingCard(snapshot: snapshot, onOpen: onOpenApprovals),
              ],
              const SizedBox(height: 24),
              _ManagementModulesSection(),
            ],
          ),
        );
      }),
    );
  }
}

class AdminTeamPage extends GetView<AdminDashboardController> {
  const AdminTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Team',
              showDivider: true,
              background: Colors.white,
              trailing: IconButton(
                onPressed: () => _openCreateUser(context),
                icon: const Icon(AppIcons.add, color: AppColors.primaryDark),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.users.isEmpty) {
                  return const CenteredProgress();
                }

                if (controller.users.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                      children: const [
                        EmptyInfoCard(
                          title: 'No team members',
                          message:
                              'Users from the management portal appear here.',
                          icon: AppIcons.people,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshData,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                    itemCount: controller.users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _UserTile(
                        key: ValueKey(controller.users[index].id),
                        user: controller.users[index],
                        index: index,
                        onChanged: controller.refreshData,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateUser(BuildContext context) async {
    final changed = await showAdminCreateUserSheet(context);
    if (!changed) return;
    await controller.refreshData();
  }
}

class AdminApprovalsPage extends GetView<AdminDashboardController> {
  const AdminApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Approvals',
              showDivider: true,
              background: Colors.white,
            ),
            Expanded(
              child: Obx(() {
                final activeTab = controller.activeApprovalTab.value;
                final selectedStatus = controller.activeApprovalStatus;
                final statusLabel = _approvalStatusLabel(selectedStatus);
                final approvals = activeTab == AdminApprovalTab.leave
                    ? controller.leaveApprovals
                    : controller.deviceApprovals;
                final title = activeTab == AdminApprovalTab.leave
                    ? 'Leave Requests'
                    : 'Device Requests';
                final requestLabel = activeTab == AdminApprovalTab.leave
                    ? 'leave request'
                    : 'device request';
                final subtitle = approvals.isEmpty
                    ? _approvalEmptyMessage(
                        status: selectedStatus,
                        requestLabel: requestLabel,
                      )
                    : _approvalCountMessage(
                        count: approvals.length,
                        statusLabel: statusLabel,
                        status: selectedStatus,
                        requestLabel: requestLabel,
                      );
                final emptyTitle = activeTab == AdminApprovalTab.leave
                    ? 'No Leave Requests'
                    : 'No Device Requests';
                final emptyMessage = _approvalEmptyMessage(
                  status: selectedStatus,
                  requestLabel: requestLabel,
                );

                if (controller.isApprovalsLoading.value && approvals.isEmpty) {
                  return const CenteredProgress();
                }

                if (controller.errorText.value != null &&
                    approvals.isEmpty &&
                    !controller.isApprovalsLoading.value) {
                  return CenterErrorView(
                    message: controller.errorText.value!,
                    onRetry: controller.refreshApprovals,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshApprovals,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                    children: [
                      _ApprovalTabSwitcher(
                        selectedTab: activeTab,
                        onChanged: controller.setActiveApprovalTab,
                      ),
                      const SizedBox(height: 18),
                      _ApprovalFiltersPanel(
                        controller: controller,
                        activeTab: activeTab,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (controller.isApprovalsLoading.value &&
                          approvals.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            color: AppColors.primaryDark,
                            backgroundColor: AppColors.border,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (approvals.isEmpty)
                        EmptyInfoCard(
                          title: emptyTitle,
                          message: emptyMessage,
                          icon: activeTab == AdminApprovalTab.leave
                              ? AppIcons.leaves
                              : AppIcons.mobile,
                        )
                      else
                        ...approvals.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == approvals.length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: _ApprovalTile(item: entry.value),
                          );
                        }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminProfilePage extends GetView<AuthController> {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(
              title: 'Profile',
              showDivider: true,
              background: Colors.white,
            ),
            Expanded(
              child: Obx(() {
                final profile = controller.user.value;
                if (profile == null) return const CenteredProgress();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                  children: [
                    _ProfileSummary(
                      name: profile.fullName,
                      email: profile.email,
                      roles: profile.roles,
                      isActive: profile.isActive,
                    ),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.signOut,
                      icon: const Icon(
                        AppIcons.logout,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
