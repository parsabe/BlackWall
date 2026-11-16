import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/telemetry_model.dart';
import '../models/server_config.dart';
import '../services/blackwall_service.dart';

class ChatProvider extends ChangeNotifier {
  final BlackWallService _blackwallService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  TelemetryModel? _lastTelemetry;

  ChatProvider(this._blackwallService);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  TelemetryModel? get lastTelemetry => _lastTelemetry;

  Future<void> sendPrompt(String text, ServerConfig config) async {
    final prompt = text.trim();
    if (prompt.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
      sender: MessageSender.user,
      text: prompt,
      status: 'pending',
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    final result = await _blackwallService.executePrompt(
      prompt: prompt,
      config: config,
    );

    _lastTelemetry = result.telemetry;

    final assistantMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_bw',
      sender: MessageSender.blackwall,
      text: result.response ?? '',
      status: result.status,
      message: result.message,
      telemetry: result.telemetry,
      timestamp: DateTime.now(),
    );

    _messages.add(assistantMessage);
    _isLoading = false;
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _lastTelemetry = null;
    notifyListeners();
  }
}
