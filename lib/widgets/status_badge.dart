import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'released':
        bg = AppTheme.safeGreen.withValues(alpha: 0.15);
        fg = AppTheme.safeGreen;
        icon = Icons.verified_user_outlined;
        label = 'RELEASED (VETTED)';
        break;
      case 'blocked_ingress':
        bg = AppTheme.criticalRed.withValues(alpha: 0.15);
        fg = AppTheme.criticalRed;
        icon = Icons.block;
        label = 'BLOCKED: INGRESS';
        break;
      case 'blocked_egress':
        bg = Colors.purpleAccent.withValues(alpha: 0.15);
        fg = Colors.purpleAccent;
        icon = Icons.shield_outlined;
        label = 'BLOCKED: EGRESS';
        break;
      case 'offline':
        bg = AppTheme.warningAmber.withValues(alpha: 0.15);
        fg = AppTheme.warningAmber;
        icon = Icons.cloud_off;
        label = 'FAIL-CLOSED (OFFLINE)';
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey;
        icon = Icons.hourglass_top;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
