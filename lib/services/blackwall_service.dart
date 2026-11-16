import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/telemetry_model.dart';
import '../models/server_config.dart';

class BlackWallResult {
  final String status; // released, blocked_ingress, blocked_egress, offline
  final String? response;
  final String? message;
  final TelemetryModel telemetry;

  BlackWallResult({
    required this.status,
    this.response,
    this.message,
    required this.telemetry,
  });
}

class BlackWallService {
  Future<BlackWallResult> executePrompt({
    required String prompt,
    required ServerConfig config,
  }) async {
    final client = http.Client();
    final stopwatch = Stopwatch()..start();

    try {
      final endpoint = config.activeEndpoint;
      final uri = Uri.parse(endpoint);

      final response = await client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'prompt': prompt}),
          )
          .timeout(Duration(seconds: config.timeoutSeconds));

      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        final status = body['status'] as String? ?? 'released';
        final responseText = body['response'] as String?;
        final message = body['message'] as String?;
        final telemetryData = body['telemetry'] as Map<String, dynamic>?;

        final telemetry = TelemetryModel.fromMap(telemetryData);

        return BlackWallResult(
          status: status,
          response: responseText,
          message: message,
          telemetry: telemetry,
        );
      } else {
        // HTTP Error -> Fail Closed
        return BlackWallResult(
          status: 'offline',
          response: null,
          message: 'Server returned HTTP ${response.statusCode}: ${response.reasonPhrase}. Fail-Closed active.',
          telemetry: TelemetryModel(totalLatencyMs: stopwatch.elapsedMilliseconds.toDouble()),
        );
      }
    } on TimeoutException {
      stopwatch.stop();
      return BlackWallResult(
        status: 'offline',
        response: null,
        message: 'Request timed out after ${config.timeoutSeconds}s. Host inference window exceeded (CPU hosts may require 60-100s). Fail-Closed active.',
        telemetry: TelemetryModel(totalLatencyMs: stopwatch.elapsedMilliseconds.toDouble()),
      );
    } catch (e) {
      stopwatch.stop();
      return BlackWallResult(
        status: 'offline',
        response: null,
        message: 'Connection failed (${e.toString()}). Guardrail barrier unreachable. Fail-Closed active.',
        telemetry: TelemetryModel(totalLatencyMs: stopwatch.elapsedMilliseconds.toDouble()),
      );
    } finally {
      client.close();
    }
  }
}
