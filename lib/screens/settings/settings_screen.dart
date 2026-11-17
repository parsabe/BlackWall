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

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? '');
    final emailCtrl =
        TextEditingController(text: auth.currentUser?.email ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await auth.updateProfile(
                name: nameCtrl.text,
                email: emailCtrl.text,
              );
              if (ctx.mounted) Navigator.of(ctx).pop(ok);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    emailCtrl.dispose();

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } else if (saved == false && context.mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Current password required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => v == null || v.length < 6
                    ? 'Minimum 6 characters required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await auth.changePassword(
                currentPassword: currentCtrl.text,
                newPassword: newCtrl.text,
              );
              if (ctx.mounted) Navigator.of(ctx).pop(ok);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    currentCtrl.dispose();
    newCtrl.dispose();

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } else if (saved == false && context.mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently remove your local operator account and sign you out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.criticalRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.deleteAccount();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final config = settings.config;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final borderColor = theme.dividerColor;

    final token = auth.currentUser?.token ?? '';
    final tokenPreview =
        token.length > 16 ? '${token.substring(0, 16)}...' : token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Settings & Appearance Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                color: primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Account Settings',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Operator: ${auth.currentUser?.name ?? "Anonymous"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email: ${auth.currentUser?.email ?? "N/A"}',
                          style:
                              TextStyle(fontSize: 13, color: onSurfaceVariant),
                        ),
                        if (tokenPreview.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Session Token: $tokenPreview',
                            style: TextStyle(
                                fontSize: 12, color: onSurfaceVariant),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Divider(color: borderColor),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.palette_outlined,
                                color: primary, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Appearance',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode_outlined, size: 16),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode_outlined, size: 16),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto_outlined,
                                  size: 16),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (selection) {
                            settings.updateThemeMode(selection.first);
                          },
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showEditProfileDialog(context),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Profile'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showChangePasswordDialog(context),
                              icon: const Icon(Icons.lock_reset_outlined,
                                  size: 16),
                              label: const Text('Change Password'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                await auth.logout();
                                navigator.pop();
                              },
                              icon: const Icon(Icons.logout,
                                  size: 16, color: AppTheme.warningAmber),
                              label: const Text(
                                'Sign Out',
                                style: TextStyle(color: AppTheme.warningAmber),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppTheme.warningAmber),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _confirmDeleteAccount(context),
                              icon: const Icon(Icons.delete_forever_outlined,
                                  size: 16, color: AppTheme.criticalRed),
                              label: const Text(
                                'Delete Account',
                                style: TextStyle(color: AppTheme.criticalRed),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppTheme.criticalRed),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gateway Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.router_outlined,
                                color: primary, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Gateway Endpoint',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the target BlackWall Guardrail Gateway.',
                          style:
                              TextStyle(fontSize: 13, color: onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                        RadioGroup<ServerMode>(
                          groupValue: config.mode,
                          onChanged: (val) {
                            if (val != null) settings.updateMode(val);
                          },
                          child: Column(
                            children: [
                              RadioListTile<ServerMode>(
                                title: const Text(
                                  'Production Remote Gateway',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  AppConstants.defaultRemoteGateway,
                                  style:
                                      TextStyle(fontSize: 12, color: primary),
                                ),
                                value: ServerMode.remoteGateway,
                              ),
                              Divider(height: 1, color: borderColor),
                              RadioListTile<ServerMode>(
                                title: const Text(
                                  'Local Host Gateway',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  AppConstants.defaultLocalGateway,
                                  style:
                                      TextStyle(fontSize: 12, color: primary),
                                ),
                                value: ServerMode.localGateway,
                              ),
                              Divider(height: 1, color: borderColor),
                              RadioListTile<ServerMode>(
                                title: const Text(
                                  'Custom Dedicated Endpoint',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Point to private or enterprise gateway',
                                  style: TextStyle(
                                      fontSize: 12, color: onSurfaceVariant),
                                ),
                                value: ServerMode.custom,
                              ),
                            ],
                          ),
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

                // Timeout Card
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
                              'Request Timeout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Timeout Limit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${config.timeoutSeconds}s',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: 15,
                          max: 180,
                          divisions: 33,
                          value: config.timeoutSeconds.toDouble(),
                          activeColor: primary,
                          onChanged: (val) {
                            settings.updateTimeout(val.toInt());
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('15s (GPU)',
                                style: TextStyle(
                                    fontSize: 11, color: onSurfaceVariant)),
                            const Text('90s (CPU)',
                                style: TextStyle(
                                    fontSize: 11, color: AppTheme.safeGreen)),
                            Text('180s (Deep)',
                                style: TextStyle(
                                    fontSize: 11, color: onSurfaceVariant)),
                          ],
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
