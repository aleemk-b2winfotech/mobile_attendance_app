import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';

abstract class AdminDataController<
  TRepository extends AdminRepositoryBase,
  TRow
>
    extends GetxController {
  AdminDataController(this.repository);

  final TRepository repository;

  final RxList<TRow> rows = <TRow>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorText = RxnString();

  Future<void> load();

  Future<void> runLoad(Future<List<TRow>> Function() request) async {
    isLoading.value = true;
    errorText.value = null;

    try {
      rows.assignAll(await request());
    } catch (error) {
      errorText.value = repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }
}

abstract class AdminPagedDataController<
  TRepository extends AdminRepositoryBase,
  TRow
>
    extends AdminDataController<TRepository, TRow> {
  AdminPagedDataController(super.repository);

  final Rx<AdminPaginationMeta> meta = const AdminPaginationMeta.empty().obs;
  final RxInt page = 1.obs;

  Future<void> goToPage(int nextPage) async {
    page.value = nextPage;
    await load();
  }

  Future<void> runPagedLoad(
    Future<AdminPagedResult<TRow>> Function() request,
  ) async {
    isLoading.value = true;
    errorText.value = null;

    try {
      final result = await request();
      rows.assignAll(result.rows);
      meta.value = result.meta;
    } catch (error) {
      errorText.value = repository.toReadableError(error);
    } finally {
      isLoading.value = false;
    }
  }
}

String adminText(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String adminIsoDay(Object? value) {
  final text = adminText(value);
  if (text.length <= 10) return text;
  return text.substring(0, 10);
}

String adminMonthStart() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month));
}

String adminMonthEnd() {
  final now = DateTime.now();
  return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
}
