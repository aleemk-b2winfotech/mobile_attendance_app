import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'present':
    case 'completed':
    case 'approved':
      return AppColors.successDark;
    case 'working':
    case 'halfday':
    case 'half_day':
    case 'regularized':
      return AppColors.infoDark;
    case 'pending':
    case 'onleave':
    case 'on_leave':
    case 'absent':
      return AppColors.warningDark;
    case 'rejected':
      return AppColors.dangerDark;
    case 'cancelled':
      return AppColors.textSecondary;
    case 'holiday':
    case 'weeklyoff':
    case 'weekly_off':
      return const Color(0xFF7C3AED);
    default:
      return AppColors.primary;
  }
}

Color statusSoftColor(String status) {
  switch (status.toLowerCase()) {
    case 'present':
    case 'completed':
    case 'approved':
      return const Color(0xFFD1FAE5);
    case 'working':
    case 'halfday':
    case 'half_day':
    case 'regularized':
      return const Color(0xFFDBEAFE);
    case 'pending':
    case 'onleave':
    case 'on_leave':
    case 'absent':
      return const Color(0xFFFEF3C7);
    case 'rejected':
      return const Color(0xFFFECACA);
    case 'cancelled':
      return const Color(0xFFF1F5F9);
    case 'holiday':
    case 'weeklyoff':
    case 'weekly_off':
      return const Color(0xFFEDE9FE);
    default:
      return const Color(0xFFE2E8F0);
  }
}

IconData statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'present':
    case 'completed':
    case 'approved':
      return AppIcons.present;
    case 'working':
    case 'pending':
    case 'onleave':
    case 'on_leave':
      return AppIcons.pending;
    case 'halfday':
    case 'half_day':
    case 'regularized':
      return AppIcons.halfDay;
    case 'absent':
    case 'rejected':
      return AppIcons.absent;
    case 'holiday':
    case 'weeklyoff':
    case 'weekly_off':
      return AppIcons.holiday;
    default:
      return AppIcons.present;
  }
}
