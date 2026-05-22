import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/formatters.dart';
import 'package:app/core/widgets/app_header.dart';
import 'package:app/core/widgets/app_toast.dart';
import 'package:app/features/auth/domain/models/auth_models.dart';
import 'package:app/features/employee/profile/presentation/controllers/profile_controller.dart';

part 'widgets/profile_page_widgets.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.user.value;
      if (profile == null) {
        return const Scaffold(
          backgroundColor: AppColors.scaffold,
          body: SafeArea(child: Center(child: Text('Not logged in'))),
        );
      }

      final latitude = profile.attendance?.officeLatitude;
      final longitude = profile.attendance?.officeLongitude;
      final radius = profile.attendance?.officeRadiusMeters;
      final hasLocation = latitude != null && longitude != null;

      final locationSubtitleParts = <String>[
        if (radius != null) 'Radius $radius m',
        if (hasLocation) 'Tap to view on map',
      ];

      final details = <_DetailItem>[
        _DetailItem(
          icon: AppIcons.profileCard,
          label: 'Name',
          value: profile.fullName,
        ),
        _DetailItem(icon: AppIcons.mail, label: 'Email', value: profile.email),
        _DetailItem(
          icon: AppIcons.profileTick,
          label: 'Status',
          value: profile.isActive ? 'Active' : 'Inactive',
        ),
        _DetailItem(
          icon: AppIcons.people,
          label: 'Manager',
          value: profile.manager?.fullName ?? 'Not assigned',
          subtitle: profile.manager?.email,
        ),
        _DetailItem(
          icon: AppIcons.location,
          label: 'Office Location',
          value: hasLocation
              ? '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
              : 'Not available',
          subtitle: locationSubtitleParts.isEmpty
              ? null
              : locationSubtitleParts.join(' • '),
          onTap: hasLocation
              ? () => _openOfficeMap(context, latitude, longitude)
              : null,
        ),
      ];

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppHeader(
                title: 'Profile',
                showDivider: true,
                background: Colors.white,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  children: [
                    _ProfileHero(profile: profile),
                    const SizedBox(height: 18),
                    Container(
                      decoration: AppTheme.cardDecoration(
                        background: const Color(0x0D1D3C8B),
                        borderColor: const Color(0x0D1D3C8B),
                        radius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: _SectionHeader(
                              icon: AppIcons.profile,
                              title: 'Personal Details',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.cardDecoration(
                              radius: const BorderRadius.only(
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              borderColor: const Color(0x0D1D3C8B),
                            ),
                            child: Column(
                              children: List.generate(details.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == details.length - 1
                                        ? 0
                                        : 14,
                                  ),
                                  child: _DetailRow(item: details[index]),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => _confirmSignOut(context),
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.danger,
                                ),
                              )
                            : const Icon(
                                AppIcons.logout,
                                color: AppColors.danger,
                                size: 18,
                              ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.blueGrey.shade100,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await controller.signOut();
    }
  }

  Future<void> _openOfficeMap(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final opened = await controller.openOfficeMap(
      latitude: latitude,
      longitude: longitude,
    );

    if (!context.mounted || opened) return;

    AppToast.error('Unable to open map.');
  }
}
