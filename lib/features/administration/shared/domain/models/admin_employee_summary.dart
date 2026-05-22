import 'package:app/features/administration/shared/domain/models/admin_json_helpers.dart';

class AdminEmployeeSummary {
  const AdminEmployeeSummary({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String fullName;
  final String email;

  factory AdminEmployeeSummary.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const AdminEmployeeSummary(
        id: '',
        fullName: 'Employee',
        email: '',
      );
    }
    return AdminEmployeeSummary(
      id: adminText(value['id']),
      fullName: adminText(value['fullName'], fallback: 'Employee'),
      email: adminText(value['email']),
    );
  }
}
