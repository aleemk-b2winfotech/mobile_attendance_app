import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CenteredProgress extends StatelessWidget {
  const CenteredProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
