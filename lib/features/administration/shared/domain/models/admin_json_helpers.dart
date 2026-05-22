Map<String, String> adminUserMap(Object? value) {
  if (value is! Map<String, dynamic>) return const <String, String>{};
  return <String, String>{
    if (value['fullName'] != null) 'fullName': value['fullName'].toString(),
    if (value['email'] != null) 'email': value['email'].toString(),
    if (value['id'] != null) 'id': value['id'].toString(),
  };
}

double adminToDouble(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

String adminIsoDay(Object? value) {
  final text = adminText(value);
  if (text.length <= 10) return text;
  return text.substring(0, 10);
}

String adminText(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? adminNullableText(Object? value) {
  final text = adminText(value);
  return text.isEmpty ? null : text;
}
