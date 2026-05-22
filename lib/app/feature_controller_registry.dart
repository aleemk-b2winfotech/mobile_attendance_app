import 'package:get/get.dart';

import 'package:app/core/services/map_launcher_service.dart';
import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/analytics/data/admin_analytics_repository.dart';
import 'package:app/features/administration/approvals/data/admin_approval_repository.dart';
import 'package:app/features/administration/attendance/data/admin_attendance_repository.dart';
import 'package:app/features/administration/dashboard/data/admin_dashboard_repository.dart';
import 'package:app/features/administration/dashboard/presentation/controllers/admin_dashboard_controller.dart';
import 'package:app/features/administration/holidays/data/admin_holiday_repository.dart';
import 'package:app/features/administration/management/presentation/controllers/admin_management_controller.dart';
import 'package:app/features/administration/shell/presentation/controllers/admin_home_controller.dart';
import 'package:app/features/administration/team/data/admin_user_repository.dart';
import 'package:app/features/administration/team/presentation/controllers/admin_user_actions_controller.dart';
import 'package:app/features/administration/work_from_home/data/admin_work_from_home_repository.dart';
import 'package:app/features/employee/attendance/data/attendance_repository.dart';
import 'package:app/features/employee/attendance/presentation/controllers/attendance_controller.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/employee/dashboard/data/dashboard_repository.dart';
import 'package:app/features/employee/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:app/features/employee/dashboard/presentation/controllers/punch_flow_controller.dart';
import 'package:app/features/employee/device_change/data/device_change_repository.dart';
import 'package:app/features/employee/device_change/presentation/controllers/device_change_controller.dart';
import 'package:app/features/employee/home/presentation/controllers/home_controller.dart';
import 'package:app/features/employee/leaves/data/leave_repository.dart';
import 'package:app/features/employee/leaves/presentation/controllers/leave_controller.dart';
import 'package:app/features/employee/profile/presentation/controllers/profile_controller.dart';

class FeatureControllerRegistry {
  const FeatureControllerRegistry._();

  static void registerForPortal(ApiPortal portal) {
    if (portal == ApiPortal.admin) {
      _registerAdminControllers();
      return;
    }

    _registerEmployeeControllers();
  }

  static void clearSessionControllers() {
    _deleteIfRegistered<LeaveController>();
    _deleteIfRegistered<AttendanceController>();
    _deleteIfRegistered<DashboardController>();
    _deleteIfRegistered<PunchFlowController>();
    _deleteIfRegistered<HomeController>();
    _deleteIfRegistered<DeviceChangeController>();
    _deleteIfRegistered<ProfileController>();
    _deleteIfRegistered<AdminDashboardController>();
    _deleteIfRegistered<AdminHomeController>();
    _deleteIfRegistered<AdminUserActionsController>();
    _deleteIfRegistered<AdminAttendanceRecordsController>();
    _deleteIfRegistered<AdminAnalyticsController>();
    _deleteIfRegistered<AdminLeaveRequestsController>();
    _deleteIfRegistered<AdminDeviceRequestsController>();
    _deleteIfRegistered<AdminHolidaysController>();
    _deleteIfRegistered<AdminWorkFromHomeController>();
  }

  static void _registerEmployeeControllers() {
    _putPermanent<HomeController>(() => HomeController());
    _putPermanent<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
    );
    _putPermanent<PunchFlowController>(() => PunchFlowController());
    _putPermanent<AttendanceController>(
      () => AttendanceController(Get.find<AttendanceRepository>()),
    );
    _putPermanent<LeaveController>(
      () => LeaveController(Get.find<LeaveRepository>()),
    );
    _lazyPut<DeviceChangeController>(
      () => DeviceChangeController(
        Get.find<DeviceChangeRepository>(),
        Get.find<AuthController>(),
      ),
    );
    _lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<AuthController>(),
        Get.find<MapLauncherService>(),
      ),
    );
  }

  static void _registerAdminControllers() {
    _putPermanent<AdminHomeController>(() => AdminHomeController());
    _putPermanent<AdminDashboardController>(
      () => AdminDashboardController(
        Get.find<AdminDashboardRepository>(),
        Get.find<AdminUserRepository>(),
        Get.find<AdminApprovalRepository>(),
      ),
    );
    _putPermanent<AdminUserActionsController>(
      () => AdminUserActionsController(
        Get.find<AdminUserRepository>(),
        Get.find<AuthController>(),
      ),
    );
    _lazyPut<AdminAttendanceRecordsController>(
      () => AdminAttendanceRecordsController(
        Get.find<AdminAttendanceRepository>(),
      ),
    );
    _lazyPut<AdminAnalyticsController>(
      () => AdminAnalyticsController(Get.find<AdminAnalyticsRepository>()),
    );
    _lazyPut<AdminLeaveRequestsController>(
      () => AdminLeaveRequestsController(Get.find<AdminApprovalRepository>()),
    );
    _lazyPut<AdminDeviceRequestsController>(
      () => AdminDeviceRequestsController(Get.find<AdminApprovalRepository>()),
    );
    _lazyPut<AdminHolidaysController>(
      () => AdminHolidaysController(Get.find<AdminHolidayRepository>()),
    );
    _lazyPut<AdminWorkFromHomeController>(
      () => AdminWorkFromHomeController(
        Get.find<AdminWorkFromHomeRepository>(),
        Get.find<AdminUserRepository>(),
      ),
    );
  }

  static void _putPermanent<T>(T Function() create) {
    if (!Get.isRegistered<T>()) {
      Get.put<T>(create(), permanent: true);
    }
  }

  static void _lazyPut<T>(T Function() create) {
    if (!Get.isRegistered<T>()) {
      Get.lazyPut<T>(create, fenix: true);
    }
  }

  static void _deleteIfRegistered<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }
}
