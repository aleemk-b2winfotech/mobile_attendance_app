import 'package:flutter/material.dart';

class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
