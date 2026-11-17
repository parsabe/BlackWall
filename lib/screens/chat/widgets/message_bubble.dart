import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';
import '../../../widgets/status_badge.dart';
import 'formatted_message_text.dart';
import 'telemetry_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final borderColor = theme.dividerColor;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    // BlackWall Assistant Output
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getBorderColor(message.status, borderColor),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 15, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        'BlackWall',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: message.status),
                ],
              ),
            ),
            Divider(height: 18, color: borderColor),

            // Warning or Alert message if blocked or offline
            if (message.message != null && message.message!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getAlertBgColor(message.status, theme),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getAlertIcon(message.status),
                      size: 16,
                      color: _getAlertFgColor(message.status, theme),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.message!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getAlertFgColor(message.status, theme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Released Vetted Response with formatted code blocks
            if (message.isReleased && message.text.isNotEmpty)
              FormattedMessageText(
                text: message.text,
                textColor: theme.colorScheme.onSurface,
                fontSize: 14,
              ),

            // Trace Telemetry Card
            if (message.telemetry != null)
              TelemetryCard(telemetry: message.telemetry!),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(String status, Color defaultBorder) {
    switch (status) {
      case 'released':
        return defaultBorder;
      case 'blocked_ingress':
        return AppTheme.criticalRed.withValues(alpha: 0.45);
      case 'blocked_egress':
        return Colors.purpleAccent.withValues(alpha: 0.45);
      case 'offline':
        return AppTheme.warningAmber.withValues(alpha: 0.45);
      default:
        return defaultBorder;
    }
  }

  Color _getAlertBgColor(String status, ThemeData theme) {
    switch (status) {
      case 'released':
        return AppTheme.safeGreen.withValues(alpha: 0.1);
      case 'blocked_ingress':
      case 'blocked_egress':
        return AppTheme.criticalRed.withValues(alpha: 0.1);
      case 'offline':
        return AppTheme.warningAmber.withValues(alpha: 0.12);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getAlertFgColor(String status, ThemeData theme) {
    switch (status) {
      case 'released':
        return AppTheme.safeGreen;
      case 'blocked_ingress':
      case 'blocked_egress':
        return AppTheme.criticalRed;
      case 'offline':
        return AppTheme.warningAmber;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getAlertIcon(String status) {
    switch (status) {
      case 'released':
        return Icons.check_circle_outline;
      case 'blocked_ingress':
        return Icons.security_update_warning;
      case 'blocked_egress':
        return Icons.privacy_tip_outlined;
      case 'offline':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
