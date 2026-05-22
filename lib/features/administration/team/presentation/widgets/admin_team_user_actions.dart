import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/core/widgets/button_spinner.dart';
import 'package:app/core/widgets/sheet_padding.dart';
import 'package:app/core/widgets/status_chip.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/administration/team/presentation/controllers/admin_user_actions_controller.dart';

part 'admin_team_user_actions/create_user_sheet.dart';
part 'admin_team_user_actions/user_edit_dialogs.dart';
part 'admin_team_user_actions/user_device_logs_sheet.dart';
part 'admin_team_user_actions/user_location_sheet.dart';
part 'admin_team_user_actions/user_manager_sheet.dart';

Future<bool> showAdminCreateUserSheet(BuildContext context) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _AdminCreateUserSheet(),
  );
  return changed ?? false;
}

Future<bool> showAdminUserNameEditDialog(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _AdminUserNameDialog(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserRolePromotionDialog(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _AdminUserRolePromotionDialog(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserLocationSheet(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _AdminUserLocationSheet(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserManagerSheet(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _AdminUserManagerSheet(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserDeviceLogsSheet(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _AdminUserDeviceLogsSheet(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserActivateDialog(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _AdminUserActivateDialog(user: user),
  );
  return changed ?? false;
}

Future<bool> showAdminUserDeactivateDialog(
  BuildContext context, {
  required AdminUser user,
}) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => _AdminUserDeactivateDialog(user: user),
  );
  return changed ?? false;
}

String _text(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

void _showSnack(BuildContext context, String message, {required bool isError}) {
  AppToast.show(message, isError: isError);
}
