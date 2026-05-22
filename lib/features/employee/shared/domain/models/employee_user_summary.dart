class EmployeeUserSummary {
  const EmployeeUserSummary({
    required this.id,
    required this.fullName,
    required this.email,
    this.roles = const <String>[],
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName;
    if (email.trim().isNotEmpty) return email;
    return id;
  }

  factory EmployeeUserSummary.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const EmployeeUserSummary(id: '', fullName: '', email: '');
    }

    return EmployeeUserSummary(
      id: _text(value['id']),
      fullName: _firstText(value, const ['fullName', 'name', 'displayName']),
      email: _text(value['email']),
      roles: (value['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

String _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _text(json[key]);
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _text(Object? value) {
  return value?.toString().trim() ?? '';
}
