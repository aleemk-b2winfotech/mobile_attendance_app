import 'package:get/get.dart';

import '../core/services/map_launcher_service.dart';
import '../data/network/api_client.dart';
import '../data/services/device_id_service.dart';
import '../features/administration/analytics/data/admin_analytics_repository.dart';
import '../features/administration/approvals/data/admin_approval_repository.dart';
import '../features/administration/attendance/data/admin_attendance_repository.dart';
import '../features/administration/dashboard/data/admin_dashboard_repository.dart';
import '../features/administration/holidays/data/admin_holiday_repository.dart';
import '../features/administration/team/data/admin_user_repository.dart';
import '../features/administration/work_from_home/data/admin_work_from_home_repository.dart';
import '../features/employee/attendance/data/attendance_repository.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/employee/dashboard/data/dashboard_repository.dart';
import '../features/employee/device_change/data/device_change_repository.dart';
import '../features/employee/leaves/data/leave_repository.dart';
import 'app_navigator.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);
    Get.put(DeviceIdService(), permanent: true);
    Get.put(MapLauncherService(), permanent: true);
    Get.put(AppNavigator(), permanent: true);
    Get.put(AuthRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(DashboardRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AttendanceRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(LeaveRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(DeviceChangeRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminDashboardRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminUserRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminApprovalRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminAttendanceRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminAnalyticsRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(AdminHolidayRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(
      AdminWorkFromHomeRepository(Get.find<ApiClient>()),
      permanent: true,
    );
    Get.put(
      AuthController(
        Get.find<AuthRepository>(),
        Get.find<DeviceIdService>(),
        Get.find<AppNavigator>(),
      ),
      permanent: true,
    );
  }
}
