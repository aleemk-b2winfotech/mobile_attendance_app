import 'package:get/get.dart';

import 'package:app/core/services/map_launcher_service.dart';
import 'package:app/features/auth/domain/models/auth_models.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  ProfileController(this._authController, this._mapLauncher);

  final AuthController _authController;
  final MapLauncherService _mapLauncher;

  Rxn<UserProfile> get user => _authController.user;

  RxBool get isLoading => _authController.isLoading;

  Future<void> signOut() {
    return _authController.signOut();
  }

  Future<bool> openOfficeMap({
    required double latitude,
    required double longitude,
  }) {
    return _mapLauncher.openCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
