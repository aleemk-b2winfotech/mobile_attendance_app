class AdminPaginationMeta {
  const AdminPaginationMeta({required this.page, required this.totalPages});

  const AdminPaginationMeta.empty() : page = 1, totalPages = 1;

  final int page;
  final int totalPages;

  factory AdminPaginationMeta.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const AdminPaginationMeta.empty();
    }
    return AdminPaginationMeta(
      page: _toInt(value['page'], fallback: 1),
      totalPages: _toInt(value['totalPages'], fallback: 1),
    );
  }
}

class AdminPagedResult<T> {
  const AdminPagedResult({required this.rows, required this.meta});

  final List<T> rows;
  final AdminPaginationMeta meta;
}

int _toInt(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
