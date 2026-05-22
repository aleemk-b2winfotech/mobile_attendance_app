import 'package:flutter/material.dart';

import '../utils/status_styles.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.compact = false,
  });

  final String label;
  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = statusColor(status);
    final background = statusSoftColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
