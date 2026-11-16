import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/server_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _customUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final config = context.read<SettingsProvider>().config;
    _customUrlController.text = config.customEndpoint;
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final config = settings.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GATEWAY CONFIGURATION'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gateway Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.router_outlined,
                                color: AppTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ENDPOINT CONNECTIVITY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Select the target BlackWall Guardrail Gateway. All prompts are routed through Ingress -> Brain -> Egress inspection.',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        RadioListTile<ServerMode>(
                          title: const Text('Production Remote Gateway',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                              AppConstants.defaultRemoteGateway,
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.primary)),
                          value: ServerMode.remoteGateway,
                          groupValue: config.mode,
                          onChanged: (val) {
                            if (val != null) settings.updateMode(val);
                          },
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        RadioListTile<ServerMode>(
                          title: const Text('Local Host Gateway (Docker / K8s)',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                              'http://127.0.0.1:8080/sandbox (Ports 8000 & 11434)',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.primary)),
                          value: ServerMode.localGateway,
                          groupValue: config.mode,
                          onChanged: (val) {
                            if (val != null) settings.updateMode(val);
                          },
                        ),
                        const Divider(height: 1, color: AppTheme.border),
                        RadioListTile<ServerMode>(
                          title: const Text('Custom Dedicated Endpoint',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text(
                              'Point to private or enterprise gateway',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                          value: ServerMode.custom,
                          groupValue: config.mode,
                          onChanged: (val) {
                            if (val != null) settings.updateMode(val);
                          },
                        ),
                        if (config.mode == ServerMode.custom) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customUrlController,
                            decoration: const InputDecoration(
                              hintText: 'https://gateway.example.com/sandbox',
                              labelText: 'Custom Gateway URL',
                            ),
                            onChanged: (val) {
                              settings.updateMode(ServerMode.custom,
                                  customUrl: val.trim());
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hardware & Timeout Awareness Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                color: AppTheme.warningAmber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'HARDWARE & TIMEOUT TOLERANCE',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppTheme.warningAmber
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Notice: Dual-barrier classification plus Gemma 3 1B inference window on CPU hosts can reach 60s to 100s. Adjust timeout accordingly to prevent false fail-closed triggers.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.warningAmber,
                                height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Request Timeout Limit',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${config.timeoutSeconds} seconds',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary)),
                          ],
                        ),
                        Slider(
                          min: 15,
                          max: 180,
                          divisions: 33,
                          value: config.timeoutSeconds.toDouble(),
                          activeColor: AppTheme.primary,
                          onChanged: (val) {
                            settings.updateTimeout(val.toInt());
                          },
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('15s (GPU Quick)',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                            Text('90s (Recommended CPU)',
                                style: TextStyle(
                                    fontSize: 10, color: AppTheme.safeGreen)),
                            Text('180s (Deep Reasoning)',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Current Session Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_pin_outlined,
                                color: AppTheme.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'OPERATOR IDENTITY',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                            'Operator: ${auth.currentUser?.name ?? "Anonymous"}',
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Email: ${auth.currentUser?.email ?? "N/A"}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                            'Session Token: ${auth.currentUser?.token.substring(0, 16)}...',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            if (mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.logout,
                              size: 16, color: AppTheme.criticalRed),
                          label: const Text('TERMINATE OPERATOR SESSION',
                              style: TextStyle(
                                  color: AppTheme.criticalRed, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.criticalRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
