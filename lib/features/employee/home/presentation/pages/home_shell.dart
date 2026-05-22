import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_bottom_navigation.dart';
import 'package:app/features/employee/attendance/presentation/pages/attendance_page.dart';
import 'package:app/features/employee/dashboard/presentation/pages/dashboard_page.dart';
import 'package:app/features/employee/home/presentation/controllers/home_controller.dart';
import 'package:app/features/employee/leaves/presentation/pages/leaves_page.dart';
import 'package:app/features/employee/profile/presentation/pages/profile_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  HomeController _ensureController() {
    return Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _ensureController();
    final pages = <Widget>[
      DashboardPage(onOpenHistory: () => controller.switchTab(1)),
      const AttendancePage(),
      const LeavesPage(),
      const ProfilePage(),
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
        ),
      ),
    );
  }
}
