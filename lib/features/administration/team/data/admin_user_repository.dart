import 'package:app/data/network/api_client.dart';
import 'package:app/features/administration/shared/data/admin_repository_base.dart';
import 'package:app/features/administration/shared/data/admin_response_helpers.dart';
import 'package:app/features/administration/shared/domain/models/admin_pagination_meta.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';

class AdminUserRepository implements AdminRepositoryBase {
  AdminUserRepository(this._api);

  final ApiClient _api;

  Future<List<AdminUser>> fetchUsers({
    String? search,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await fetchUsersPage(
      search: search,
      role: role,
      isActive: isActive,
      page: page,
      limit: limit,
    );
    return adminRowsFromResponse(
      response,
    ).map(AdminUser.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchUsersPage({
    String? search,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) {
    return _api.fetchAdminUsers(
      search: search,
      role: role,
      isActive: isActive,
      page: page,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String email,
    required List<String> roles,
    String? managerUserId,
  }) {
    return _api.createAdminUser(
      fullName: fullName,
      email: email,
      roles: roles,
      managerUserId: managerUserId,
    );
  }

  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> payload,
  ) {
    return _api.updateAdminUser(id, payload);
  }

  Future<Map<String, dynamic>> deactivateUser(String id) {
    return _api.deactivateAdminUser(id);
  }

  Future<Map<String, dynamic>> activateUser(String id) {
    return _api.activateAdminUser(id);
  }

  Future<AdminUserLocationDraft> fetchUserLocation(String userId) async {
    final profile = await _api.fetchAdminUserLocation(userId);
    return AdminUserLocationDraft(
      latitude: _toDouble(profile['officeLatitude']),
      longitude: _toDouble(profile['officeLongitude']),
      radiusMeters: _toInt(profile['officeRadiusMeters'], fallback: 100),
    );
  }

  Future<Map<String, dynamic>> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) {
    return _api.updateAdminUserLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }

  Future<AdminDeviceLogResult> fetchUserDeviceChangeLogs({
    required String userId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.fetchAdminUserDeviceChangeLogs(
      userId: userId,
      status: status,
      page: page,
      limit: limit,
    );
    return AdminDeviceLogResult(
      rows: adminRowsFromResponse(
        response,
      ).map(AdminDeviceChangeLog.fromJson).toList(growable: false),
      meta: AdminPaginationMeta.fromJson(adminMetaFromResponse(response)),
    );
  }

  @override
  String toReadableError(Object error) => _api.toReadableError(error);

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
