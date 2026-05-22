class UserProfile {
  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
    required this.isActive,
    this.manager,
    this.attendance,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;
  final bool isActive;
  final ManagerProfile? manager;
  final AttendanceBinding? attendance;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      manager: json['manager'] is Map<String, dynamic>
          ? ManagerProfile.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      attendance: json['attendanceProfile'] is Map<String, dynamic>
          ? AttendanceBinding.fromJson(
              json['attendanceProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'roles': roles,
      'isActive': isActive,
      'manager': manager?.toJson(),
      'attendanceProfile': attendance?.toJson(),
    };
  }
}

class ManagerProfile {
  ManagerProfile({required this.id, required this.fullName, this.email});

  final String id;
  final String fullName;
  final String? email;

  factory ManagerProfile.fromJson(Map<String, dynamic> json) {
    return ManagerProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'fullName': fullName, 'email': email};
  }
}

class AttendanceBinding {
  AttendanceBinding({
    this.boundDeviceId,
    this.officeLatitude,
    this.officeLongitude,
    this.officeRadiusMeters,
  });

  final String? boundDeviceId;
  final double? officeLatitude;
  final double? officeLongitude;
  final int? officeRadiusMeters;

  factory AttendanceBinding.fromJson(Map<String, dynamic> json) {
    return AttendanceBinding(
      boundDeviceId: json['boundDeviceId'] as String?,
      officeLatitude: _toDouble(json['officeLatitude']),
      officeLongitude: _toDouble(json['officeLongitude']),
      officeRadiusMeters: json['officeRadiusMeters'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'boundDeviceId': boundDeviceId,
      'officeLatitude': officeLatitude,
      'officeLongitude': officeLongitude,
      'officeRadiusMeters': officeRadiusMeters,
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
