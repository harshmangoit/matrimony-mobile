import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider); // Global dynamic language watch
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
            // User Profile Header Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.1),
                      child: Text(
                        parent?.fullName.isNotEmpty == true ? parent!.fullName[0].toUpperCase() : 'P',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRoyalMaroon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parent?.fullName ?? 'Parent Account',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            parent?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.tr("account_type_label"),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRoyalMaroon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language Selector Card (Fixed Margin & Alignment for OnePlus 11)
            _buildSectionHeader(ref.tr("language_label")),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: AppTheme.primaryRoyalMaroon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ref.tr("select_language"),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
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

            // Active Subscription Status (Responsive Layout Fix for OnePlus 11)
            _buildSectionHeader(ref.tr("active_subscription")),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppTheme.secondaryGold, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paymentState.activeSubscription?['plan_name'] ?? ref.tr("free_plan"),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Status: ${paymentState.activeSubscription?['status'] ?? 'ACTIVE'}",
                                style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/plans'),
                        icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                        label: Text(
                          ref.tr("upgrade_membership"),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryRoyalMaroon,
                          side: const BorderSide(color: AppTheme.primaryRoyalMaroon),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
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

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/auth');
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  ref.tr("logout_confirm_btn"),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryRoyalMaroon,
        ),
      ),
    );
  }

  Widget _buildSecurityPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
