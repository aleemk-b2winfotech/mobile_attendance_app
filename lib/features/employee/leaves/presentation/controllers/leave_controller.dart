import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/core/widgets/app_toast.dart';
import 'package:app/features/employee/leaves/data/leave_repository.dart';
import 'package:app/features/employee/leaves/domain/models/leave_models.dart';

part 'leave_controller_form_actions.dart';
part 'leave_controller_holiday_actions.dart';
part 'leave_controller_request_actions.dart';
part 'leave_controller_thread_actions.dart';

enum LeaveScreenTab { holidays, leaves }

enum HolidayFilter { all, upcoming, past }

const Object _keepExistingStatus = Object();

class LeaveController extends GetxController {
  LeaveController(this._repository);

  static const List<String> leaveTypes = <String>[
    'Sick Leave',
    'Paid Leave',
    'Optional Leave',
    'loss of Pay Leave',
  ];

  final LeaveRepository _repository;

  final RxList<LeaveRequest> requests = <LeaveRequest>[].obs;
  final RxList<HolidayItem> holidays = <HolidayItem>[].obs;
  final RxMap<String, LeaveThread> threads = <String, LeaveThread>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isHolidayLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxSet<String> cancellingIds = <String>{}.obs;
  final RxSet<String> threadLoadingIds = <String>{}.obs;
  final RxSet<String> threadSubmittingIds = <String>{}.obs;
  final RxSet<String> acceptingProposalIds = <String>{}.obs;

  final RxnString errorText = RxnString();
  final RxnString holidayErrorText = RxnString();
  final RxnString submitError = RxnString();

  final Rx<LeaveScreenTab> activeTab = LeaveScreenTab.leaves.obs;
  final Rx<HolidayFilter> holidayFilter = HolidayFilter.all.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalRequests = 0.obs;
  final RxInt pageSize = 20.obs;
  final RxnString statusFilter = RxnString();

  final RxBool showSuccessBanner = false.obs;
  final RxString selectedLeaveType = leaveTypes.first.obs;
  final RxBool isMultiDay = false.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  late final TextEditingController reasonController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    reasonController = TextEditingController();
    loadRequests(page: 1);
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

void _showInlineSnack({required String message, required bool isError}) {
  AppToast.show(message, isError: isError);
}
