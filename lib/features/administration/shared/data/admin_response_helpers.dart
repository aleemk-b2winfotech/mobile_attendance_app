List<Map<String, dynamic>> adminRowsFromResponse(
  Map<String, dynamic> response,
) {
  final data = response['data'];
  if (data is List<dynamic>) {
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }
  if (data is Map<String, dynamic>) {
    final items = data['items'];
    if (items is List<dynamic>) {
      return items.whereType<Map<String, dynamic>>().toList(growable: false);
    }
  }
  final items = response['items'];
  if (items is List<dynamic>) {
    return items.whereType<Map<String, dynamic>>().toList(growable: false);
  }
  return const [];
}

Map<String, dynamic> adminMetaFromResponse(Map<String, dynamic> response) {
  final meta = response['meta'];
  if (meta is Map<String, dynamic>) return meta;
  final data = response['data'];
  if (data is Map<String, dynamic> && data['meta'] is Map<String, dynamic>) {
    return data['meta'] as Map<String, dynamic>;
  }
  return const {};
}
