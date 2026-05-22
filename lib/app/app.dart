import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/administration/shell/presentation/pages/admin_home_shell.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/employee/home/presentation/pages/home_shell.dart';
import 'app_binding.dart';

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      initialBinding: AppBinding(),
      home: Obx(() {
        final auth = Get.find<AuthController>();

        if (!auth.isInitialized.value) {
          return const Scaffold(
            backgroundColor: AppColors.scaffold,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (auth.isAuthenticated) {
          return auth.isAdminSession
              ? const AdminHomeShell()
              : const HomeShell();
        }

        return const LoginPage();
      }),
    );
  }
}
