import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/children_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/locale_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childrenProvider.notifier).loadChildren();
      ref.read(paymentProvider.notifier).loadPlansAndSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch
    final authState = ref.watch(authProvider);
    final childrenState = ref.watch(childrenProvider);
    final paymentState = ref.watch(paymentProvider);

    final parent = authState.parent;

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr("app_name")),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          )
        ],
      ),
      body: childrenState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(childrenProvider.notifier).loadChildren();
                await ref.read(paymentProvider.notifier).loadPlansAndSubscription();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Header Card
                    _buildAccountHeader(parent, paymentState.activeSubscription),
                    const SizedBox(height: 20),

                    // Section Title: Managed Profiles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.tr("my_candidates"),
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRoyalMaroon,
                                ),
                              ),
                              Text(
                                ref.tr("dashboard_hero_subtitle"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/profile-editor'),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(ref.tr("add_candidate")),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRoyalMaroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (childrenState.children.isEmpty)
                      _buildEmptyProfilesCard(context)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: childrenState.children.length,
                        itemBuilder: (context, index) {
                          final profile = childrenState.children[index];
                          final isSelected = childrenState.selectedChild?.id == profile.id;
                          return _buildCandidateCard(context, profile, isSelected);
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAccountHeader(parent, Map<String, dynamic>? activeSub) {
    final subPlan = activeSub?['plan_name'] ?? parent?.subscriptionStatus ?? 'FREE';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryRoyalMaroon, Color(0xFF5A1423)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${ref.tr("dashboard_welcome")} ${parent?.fullName ?? ''}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  parent?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryGold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  "$subPlan PLAN",
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfilesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, size: 38, color: AppTheme.primaryRoyalMaroon),
            ),
            const SizedBox(height: 12),
            Text(
              ref.tr("no_candidates_msg"),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/profile-editor'),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: Text(ref.tr("create_profile_btn")),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRoyalMaroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, profile, bool isSelected) {
    final isActive = profile.status.toUpperCase() == 'ACTIVE';

    return InkWell(
      onTap: () {
        ref.read(childrenProvider.notifier).selectChild(profile);
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: isSelected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryRoyalMaroon : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.1),
                    child: Text(
                      profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.primaryRoyalMaroon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${profile.firstName} ${profile.lastName}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 16, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${profile.calculatedAge} ${ref.tr("age_years")} • ${profile.gender} • ${profile.profession ?? ''}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Status Switch
                  Column(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isActive,
                          activeThumbColor: AppTheme.primaryRoyalMaroon,
                          onChanged: (val) {
                            ref.read(childrenProvider.notifier).toggleChildStatus(
                                  profile.id,
                                  val ? 'ACTIVE' : 'DISABLED',
                                );
                          },
                        ),
                      ),
                      Text(
                        profile.status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile Completion Progress Bar
              Row(
                children: [
                  Text(
                    "Score: ${profile.completionPercentage}%",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: profile.completionPercentage / 100.0,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: profile.completionPercentage >= 70
                            ? AppTheme.primaryRoyalMaroon
                            : Colors.amber.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(childrenProvider.notifier).selectChild(profile);
                        context.push('/profile-editor?child_id=${profile.id}');
                      },
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: Text(ref.tr("edit_profile"), style: const TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(childrenProvider.notifier).selectChild(profile);
                        context.push('/matches');
                      },
                      icon: const Icon(Icons.favorite_rounded, size: 14),
                      label: Text(ref.tr("view_matches"), style: const TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRoyalMaroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
