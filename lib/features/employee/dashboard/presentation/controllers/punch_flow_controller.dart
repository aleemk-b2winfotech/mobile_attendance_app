import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/features/employee/attendance/presentation/controllers/attendance_controller.dart';
import 'package:app/features/employee/dashboard/domain/models/dashboard_models.dart';
import 'package:app/features/employee/dashboard/presentation/controllers/dashboard_controller.dart';

class PunchFlowController extends GetxController {
  Future<void> handlePunch({
    required BuildContext context,
    required TodayAttendance today,
  }) async {
    final attendance = Get.find<AttendanceController>();
    final dashboard = Get.find<DashboardController>();
    final punchingOut = today.status == 'working';
    final isWfh = (today.workMode ?? '').toLowerCase() == 'wfh';

    if (punchingOut) {
      await _punchOut(
        context: context,
        today: today,
        isWfh: isWfh,
        attendance: attendance,
        dashboard: dashboard,
      );
      return;
    }

    await _punchIn(
      context: context,
      today: today,
      isWfh: isWfh,
      attendance: attendance,
      dashboard: dashboard,
    );
  }

  Future<void> _punchIn({
    required BuildContext context,
    required TodayAttendance today,
    required bool isWfh,
    required AttendanceController attendance,
    required DashboardController dashboard,
  }) async {
    double? latitude;
    double? longitude;
    String? todayPlan;

    if (isWfh) {
      todayPlan = await _askForRequiredText(
        context: context,
        title: 'WFH Today Plan',
        hintText: 'Write what you plan to work on today',
        requiredErrorText: "Today's plan is required for WFH punch in.",
        initialValue: today.todayPlan,
      );
      if (todayPlan == null) return;
    } else {
      final position = await _resolveLocation(context);
      if (position == null) return;
      latitude = position.latitude;
      longitude = position.longitude;
    }

    final success = await attendance.punchIn(
      latitude: latitude,
      longitude: longitude,
      todayPlan: todayPlan,
    );
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'You have punched in successfully.'
          : attendance.punchError.value ?? 'Unable to punch in.',
      isError: !success,
    );

    if (success) {
      await Future.wait(<Future<void>>[
        dashboard.refreshData(),
        attendance.loadOverview(),
      ]);
    }
  }

  Future<void> _punchOut({
    required BuildContext context,
    required TodayAttendance today,
    required bool isWfh,
    required AttendanceController attendance,
    required DashboardController dashboard,
  }) async {
    final confirmed = await _confirmPunchOut(context);
    if (!context.mounted || !confirmed) return;

    double? latitude;
    double? longitude;
    String? report;

    if (isWfh) {
      report = await _askForRequiredText(
        context: context,
        title: 'WFH Daily Report',
        hintText: 'Write what you completed today',
        requiredErrorText: 'Report is required for WFH punch out.',
        initialValue: today.report,
      );
      if (report == null) return;
    } else {
      final position = await _resolveLocation(context);
      if (position == null) return;
      latitude = position.latitude;
      longitude = position.longitude;
    }

    final success = await attendance.punchOut(
      latitude: latitude,
      longitude: longitude,
      report: report,
    );
    if (!context.mounted) return;

    _showSnack(
      context,
      success
          ? 'You have punched out successfully.'
          : attendance.punchError.value ?? 'Unable to punch out.',
      isError: !success,
    );

    if (success) {
      await Future.wait(<Future<void>>[
        dashboard.refreshData(),
        attendance.loadOverview(),
      ]);
    }
  }

  Future<bool> _confirmPunchOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Punch Out?'),
          content: const Text(
            'Do you really want to punch out now, or was this a mistake?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Working'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Punch Out'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<Position?> _resolveLocation(BuildContext context) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!context.mounted) return null;
    if (!enabled) {
      _showSnack(context, 'Location services are disabled.', isError: true);
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (!context.mounted) return null;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return null;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack(
        context,
        'Location permission is required to continue.',
        isError: true,
      );
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<String?> _askForRequiredText({
    required BuildContext context,
    required String title,
    required String hintText,
    required String requiredErrorText,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 15,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (!context.mounted || value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _showSnack(context, requiredErrorText, isError: true);
      return null;
    }
    return trimmed;
  }

  void _showSnack(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) return;

    AppToast.show(message, isError: isError);
  }
}
