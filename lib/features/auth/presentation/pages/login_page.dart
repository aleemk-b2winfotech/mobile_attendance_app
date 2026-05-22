import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_icons.dart';
import 'package:app/data/network/api_client.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/auth/presentation/widgets/device_change_bottom_sheet.dart';
import 'package:app/features/auth/presentation/widgets/login_illustration.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          const LoginIllustration(),
                          const SizedBox(height: 8),
                          Text(
                            'Mark your\nattendance securely',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: 280,
                            child: Text(
                              'Choose your workspace and sign in with your corporate account.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          Obx(() {
                            final message = controller.errorText.value;
                            if (message == null) return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ErrorCard(
                                message: message,
                                showDeviceChangeButton:
                                    controller.isDeviceMismatch.value,
                                onRequestDeviceChange: () =>
                                    showDeviceChangeBottomSheet(context),
                              ),
                            );
                          }),
                          Obx(() {
                            final busy = controller.isLoading.value;

                            return Column(
                              children: [
                                _LoginChoiceButton(
                                  label: 'Login as Employee',
                                  icon: AppIcons.profileCard,
                                  busy: busy,
                                  primary: true,
                                  onPressed: () => controller.signInWithGoogle(
                                    ApiPortal.employee,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LoginChoiceButton(
                                  label: 'Login as Administrator',
                                  icon: AppIcons.lock,
                                  busy: busy,
                                  onPressed: () => controller.signInWithGoogle(
                                    ApiPortal.admin,
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.6,
                                  ),
                              children: const [
                                TextSpan(
                                  text: 'By continuing, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginChoiceButton extends StatelessWidget {
  const _LoginChoiceButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: primary ? Colors.white : AppColors.primaryDark,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: primary
                    ? const AppSvg(AppAssets.googleLogo, width: 15, height: 15)
                    : Icon(icon, size: 17, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    if (primary) {
      return FilledButton(onPressed: busy ? null : onPressed, child: child);
    }

    return OutlinedButton(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryDark),
        foregroundColor: AppColors.primaryDark,
      ),
      child: child,
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.showDeviceChangeButton,
    required this.onRequestDeviceChange,
  });

  final String message;
  final bool showDeviceChangeButton;
  final VoidCallback onRequestDeviceChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.warning, color: AppColors.danger, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (showDeviceChangeButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRequestDeviceChange,
                icon: const Icon(AppIcons.mobile, size: 18),
                label: const Text('Request Device Change'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
