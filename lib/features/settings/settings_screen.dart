import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final paymentState = ref.watch(paymentProvider);
    final parent = authState.parent;

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr("settings_title")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Holder Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.12),
                      child: Text(
                        (parent?.fullName.isNotEmpty == true ? parent!.fullName[0] : 'M').toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRoyalMaroon),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parent?.fullName ?? "Member Parent",
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            parent?.email ?? '',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ref.tr("account_type_label"),
                            style: const TextStyle(color: AppTheme.primaryRoyalMaroon, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language Selector Card
            _buildSectionHeader(ref.tr("language_label")),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language_rounded, color: AppTheme.primaryRoyalMaroon),
                        const SizedBox(width: 12),
                        Text(
                          ref.tr("select_language"),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: ref.watch(localeProvider).languageCode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)')),
                      ],
                      onChanged: (langCode) {
                        if (langCode != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(langCode));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Subscription Status
            _buildSectionHeader(ref.tr("active_subscription")),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.stars_rounded, color: AppTheme.secondaryGold, size: 28),
                title: Text(
                  paymentState.activeSubscription?['plan_name'] ?? ref.tr("free_plan"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Status: ${paymentState.activeSubscription?['status'] ?? 'ACTIVE'}"),
                trailing: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ref.tr("upgrade_membership")),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Parental Control & Profile Security
            _buildSectionHeader(ref.tr("parent_privacy_sec_header")),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildSecurityPoint(
                      ref.tr("verified_profiles_title"),
                      ref.tr("verified_profiles_desc"),
                    ),
                    const Divider(),
                    _buildSecurityPoint(
                      ref.tr("photo_contact_guard_title"),
                      ref.tr("photo_contact_guard_desc"),
                    ),
                    const Divider(),
                    _buildSecurityPoint(
                      ref.tr("authentic_profile_title"),
                      ref.tr("authentic_profile_desc"),
                    ),
                    const Divider(),
                    _buildSecurityPoint(
                      ref.tr("bank_grade_security_title"),
                      ref.tr("bank_grade_security_desc"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  ref.tr("logout_confirm_btn"),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryRoyalMaroon,
        ),
      ),
    );
  }

  Widget _buildSecurityPoint(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.verified_user_rounded, color: Colors.green, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
