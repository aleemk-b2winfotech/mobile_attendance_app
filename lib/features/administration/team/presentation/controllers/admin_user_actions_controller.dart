import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:app/features/administration/team/data/admin_user_repository.dart';
import 'package:app/features/administration/team/domain/models/admin_user_models.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';

class AdminUserActionsController extends GetxController {
  AdminUserActionsController(this._repository, this._authController);

  final AdminUserRepository _repository;
  final AuthController _authController;

  static const List<String> _adminCreateRoles = [
    'EMPLOYEE',
    'MANAGER',
    'ADMIN',
  ];
  static const List<String> _managerCreateRoles = ['EMPLOYEE', 'MANAGER'];

  List<String> get callerRoles =>
      _authController.user.value?.roles ?? const <String>[];

  String? get callerId => _authController.user.value?.id;

  bool get isAdminCaller => callerRoles.contains('ADMIN');

  List<String> get createRoleOptions =>
      isAdminCaller ? _adminCreateRoles : _managerCreateRoles;

  Future<List<AdminUser>> fetchManagers() {
    return _repository.fetchUsers(role: 'MANAGER', limit: 100);
  }

  Future<String?> createUser(AdminUserDraft draft) async {
    final validationError = draft.validate();
    if (validationError != null) return validationError;

    try {
      final role = draft.role.trim();
      if (role == 'ADMIN' && !isAdminCaller) {
        return 'Only admins can assign admin role.';
      }

      await _repository.createUser(
        fullName: draft.fullName.trim(),
        email: draft.email.trim(),
        roles: [role],
        managerUserId: _managerUserIdForCreate(draft),
      );
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  Future<String?> updateName(AdminUser user, String name) async {
    final nextName = name.trim();
    if (nextName.isEmpty) return 'Name is required.';

    try {
      await _repository.updateUser(user.id, {'fullName': nextName});
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  Future<String?> updateRole(AdminUser user, String role) async {
    if (role.trim().isEmpty) return 'Role is required.';

    try {
      await _repository.updateUser(user.id, {'role': role});
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  String currentRole(AdminUser user) {
    if (user.roles.contains('ADMIN')) return 'ADMIN';
    if (user.roles.contains('MANAGER')) return 'MANAGER';
    return 'EMPLOYEE';
  }

  String? nextPromotedRole(AdminUser user) {
    final nextRole = switch (currentRole(user)) {
      'EMPLOYEE' => 'MANAGER',
      'MANAGER' => 'ADMIN',
      _ => null,
    };
    if (nextRole == null) return null;
    return _canAssignRole(nextRole) ? nextRole : null;
  }

  String roleLabel(String role) {
    return switch (role) {
      'ADMIN' => 'Admin',
      'MANAGER' => 'Manager',
      _ => 'Employee',
    };
  }

  Future<String?> promoteRole(AdminUser user) async {
    if (!user.isActive) return 'Activate user before changing role.';
    final nextRole = nextPromotedRole(user);
    if (nextRole == null) return 'Role is already at the highest level.';
    return updateRole(user, nextRole);
  }

  Future<String?> deactivateUser(AdminUser user) async {
    if (!user.isActive) return 'User is already inactive.';
    final statusError = _activeStatusError(user, action: 'deactivate');
    if (statusError != null) return statusError;

    try {
      await _repository.deactivateUser(user.id);
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  Future<String?> activateUser(AdminUser user) async {
    if (user.isActive) return 'User is already active.';
    final statusError = _activeStatusError(user, action: 'activate');
    if (statusError != null) return statusError;

    try {
      await _repository.activateUser(user.id);
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  Future<String?> changeAssignedManager(
    AdminUser user,
    String? managerUserId,
  ) async {
    if (!canChangeAssignedManager(user)) {
      return currentRole(user) == 'ADMIN'
          ? 'Admin users do not report to a manager.'
          : 'Only admins can change reporting manager.';
    }
    if (managerUserId == user.id) {
      return 'A user cannot report to themselves.';
    }

    try {
      await _repository.updateUser(user.id, {'managerUserId': managerUserId});
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  bool canSelectManagerForRole(String role) {
    return isAdminCaller && role != 'ADMIN';
  }

  bool canEditName(AdminUser user) => user.isActive;

  bool canPromoteRole(AdminUser user) {
    return user.isActive && nextPromotedRole(user) != null;
  }

  bool canChangeAssignedManager(AdminUser user) {
    return isAdminCaller && currentRole(user) != 'ADMIN';
  }

  bool canDeactivateUser(AdminUser user) {
    return user.isActive &&
        _activeStatusError(user, action: 'deactivate') == null;
  }

  bool canActivateUser(AdminUser user) {
    return !user.isActive &&
        _activeStatusError(user, action: 'activate') == null;
  }

  Future<AdminUserLocationDraft> fetchLocation(AdminUser user) async {
    return _repository.fetchUserLocation(user.id);
  }

  Future<String?> updateLocation({
    required AdminUser user,
    required AdminUserLocationDraft location,
  }) async {
    try {
      await _repository.updateUserLocation(
        userId: user.id,
        latitude: location.latitude,
        longitude: location.longitude,
        radiusMeters: location.radiusMeters,
      );
      return null;
    } catch (error) {
      return _repository.toReadableError(error);
    }
  }

  Future<AdminDeviceLogResult> fetchDeviceChangeLogs({
    required AdminUser user,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    return _repository.fetchUserDeviceChangeLogs(
      userId: user.id,
      status: status,
      page: page,
      limit: limit,
    );
  }

  String toReadableError(Object error) => _repository.toReadableError(error);

  Future<Position> resolveCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required to continue.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  String? _managerUserIdForCreate(AdminUserDraft draft) {
    if (draft.role == 'ADMIN') return null;
    if (isAdminCaller) return draft.managerUserId;
    return callerId;
  }

  bool _canAssignRole(String role) => _roleRank(role) <= _callerRoleRank;

  int get _callerRoleRank {
    if (callerRoles.contains('ADMIN')) return 3;
    if (callerRoles.contains('MANAGER')) return 2;
    return 1;
  }

  int _roleRank(String role) {
    return switch (role) {
      'ADMIN' => 3,
      'MANAGER' => 2,
      _ => 1,
    };
  }

  String? _activeStatusError(AdminUser user, {required String action}) {
    if (callerId == user.id) {
      return 'You cannot $action your own status.';
    }
    if (_roleRank(currentRole(user)) > _callerRoleRank) {
      return 'Cannot $action a user higher than your own role.';
    }
    return null;
  }
}
