import 'telemetry_model.dart';

enum MessageSender { user, blackwall }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final String status; // released, blocked_ingress, blocked_egress, offline, pending
  final String? message; // Explanation or safety alert
  final TelemetryModel? telemetry;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.status,
    this.message,
    this.telemetry,
    required this.timestamp,
  });

  bool get isUser => sender == MessageSender.user;

  bool get isReleased => status == 'released';
  bool get isBlockedIngress => status == 'blocked_ingress';
  bool get isBlockedEgress => status == 'blocked_egress';
  bool get isOffline => status == 'offline';
  bool get isPending => status == 'pending';
}
