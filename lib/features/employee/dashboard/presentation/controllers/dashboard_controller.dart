import 'package:get/get.dart';

import 'package:app/features/employee/dashboard/data/dashboard_repository.dart';
import 'package:app/features/employee/dashboard/domain/models/dashboard_models.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  final Rxn<DashboardSnapshot> snapshot = Rxn<DashboardSnapshot>();
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    errorText.value = null;

    try {
      snapshot.value = await _repository.fetchSnapshot();
    } catch (error) {
      errorText.value = _repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }
}
