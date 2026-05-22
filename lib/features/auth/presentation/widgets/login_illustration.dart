import 'package:flutter/material.dart';

import 'package:app/core/theme/app_icons.dart';

class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: Center(
        child: AppSvg(AppAssets.loginIllustration, width: 192, height: 198),
      ),
    );
  }
}
