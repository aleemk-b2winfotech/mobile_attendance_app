import 'package:get/get.dart';

import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/shell/presentation/pages/admin_home_shell.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/employee/home/presentation/pages/home_shell.dart';

class AppNavigator {
  void goToAuthenticatedHome(ApiPortal portal) {
    Get.offAll(
      () => portal == ApiPortal.admin
          ? const AdminHomeShell()
          : const HomeShell(),
    );
  }

  void goToLogin() {
    Get.offAll(() => const LoginPage());
  }
}
