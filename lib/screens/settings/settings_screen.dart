import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationNotifications = true;
  bool _newListingAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locationNotifications = prefs.getBool('locationNotifications') ?? true;
      _newListingAlerts = prefs.getBool('newListingAlerts') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userProfile;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.accentGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.accentGold,
                    child: Text(
                      profile?.initials ?? 'U',
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'User',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.email ?? auth.user?.email ?? '',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                auth.isEmailVerified
                                    ? Icons.verified
                                    : Icons.warning_amber_outlined,
                                color: auth.isEmailVerified
                                    ? AppTheme.success
                                    : AppTheme.accentGold,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                auth.isEmailVerified
                                    ? 'Verified'
                                    : 'Not verified',
                                style: TextStyle(
                                  color: auth.isEmailVerified
                                      ? AppTheme.success
                                      : AppTheme.accentGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications section
            _sectionTitle('Notifications'),
            const SizedBox(height: 12),
            _settingsTile(
              icon: Icons.notifications_outlined,
              title: 'Enable Notifications',
              subtitle: 'Receive alerts about services near you',
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _savePreference('notificationsEnabled', v);
              },
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.location_on_outlined,
              title: 'Location-Based Alerts',
              subtitle: 'Get notified about nearby services',
              value: _locationNotifications,
              enabled: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _locationNotifications = v);
                _savePreference('locationNotifications', v);
              },
            ),
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.add_location_outlined,
              title: 'New Listing Alerts',
              subtitle: 'Be informed when new places are added',
              value: _newListingAlerts,
              enabled: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _newListingAlerts = v);
                _savePreference('newListingAlerts', v);
              },
            ),
            const SizedBox(height: 24),

            // Account section
            _sectionTitle('Account'),
            const SizedBox(height: 12),
            _actionTile(
              icon: Icons.email_outlined,
              title: 'Verify Email',
              subtitle: 'Send a verification email',
              onTap: () async {
                await auth.sendEmailVerification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email sent!'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            _actionTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Kigali City Services v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.cardDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Sign Out',
                          style: TextStyle(color: AppTheme.textPrimary)),
                      content: const Text(
                          'Are you sure you want to sign out?',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel',
                              style:
                                  TextStyle(color: AppTheme.textMuted)),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    auth.signOut();
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppTheme.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      );

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: enabled
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value && enabled,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppTheme.accentGold,
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.divider,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentGold, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppTheme.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
