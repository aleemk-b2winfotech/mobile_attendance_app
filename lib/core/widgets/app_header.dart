import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.background = AppColors.scaffold,
    this.showDivider = false,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color background;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: background,
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0x1A1D3C8B)))
            : null,
      ),
      child: Row(
        children: [
          _Slot(
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      AppIcons.arrowBack,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _Slot(child: trailing),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 40, height: 40, child: child);
  }
}
