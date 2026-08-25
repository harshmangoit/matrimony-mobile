import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/profile_image_widget.dart';
import '../../providers/children_provider.dart';
import '../../providers/matches_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/indian_data_constants.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final child = ref.read(childrenProvider).selectedChild;
      if (child != null) {
        ref.read(matchesProvider.notifier).loadMatches(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch
    final childrenState = ref.watch(childrenProvider);
    final matchesState = ref.watch(matchesProvider);
    final selectedChild = childrenState.selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: Text("${ref.tr("verified_matches")} (${selectedChild?.firstName ?? ''})"),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final currentCode = ref.read(localeProvider).languageCode;
              final newCode = currentCode == 'hi' ? 'en' : 'hi';
              await ref.read(localeProvider.notifier).setLocale(Locale(newCode));
              if (selectedChild != null) {
                ref.read(matchesProvider.notifier).loadMatches(selectedChild.id);
              }
            },
            icon: const Icon(Icons.language_rounded, size: 18, color: AppTheme.primaryRoyalMaroon),
            label: Text(
              ref.watch(localeProvider).languageCode == 'hi' ? 'English' : 'हिंदी',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryRoyalMaroon),
            ),
          ),
        ],
      ),
      body: selectedChild == null
          ? Center(child: Text(ref.tr("no_candidates_msg")))
          : matchesState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : matchesState.errorMessage != null
                  ? _buildErrorScreen(context, matchesState.errorMessage!)
                  : matchesState.matches.isEmpty
                      ? _buildEmptyMatches()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: matchesState.matches.length,
                          itemBuilder: (context, index) {
                            final match = matchesState.matches[index];
                            return _buildMatchCard(context, match, selectedChild.id);
                          },
                        ),
    );
  }

  Widget _buildEmptyMatches() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              ref.tr("verified_matches"),
              style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr("dashboard_hero_subtitle"),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, match, int requesterChildId) {
    final score = match.matchScore;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileImageWidget(
                  photoUrl: match.photoUrl,
                  name: match.displayName,
                  radius: 26,
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
                              match.displayName,
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
                      if (match.ageAndGender != null)
                        Text(
                          match.ageAndGender!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      if (match.location != null)
                        Text(
                          match.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRoyalMaroon,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$score%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        ref.tr("compatibility_match"),
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Permitted summary details
            if (match.profession != null || match.education != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.softRoseBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    if (match.profession != null)
                      Row(
                        children: [
                          const Icon(Icons.work_outline, size: 15, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${ref.tr("profession")}: ${IndianDataConstants.formatValue(match.profession, ref.watch(localeProvider).languageCode == 'hi')}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    if (match.profession != null && match.education != null)
                      const SizedBox(height: 4),
                    if (match.education != null)
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, size: 15, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${ref.tr("qualification")}: ${IndianDataConstants.formatValue(match.education, ref.watch(localeProvider).languageCode == 'hi')}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/match-detail?candidate_id=${match.childProfileId}&child_id=$requesterChildId');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRoyalMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  ref.tr("view_full_details"),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String errorMsg) {
    final isSubscriptionError = errorMsg.toLowerCase().contains("subscription") ||
                                 errorMsg.toLowerCase().contains("payment") ||
                                 errorMsg.toLowerCase().contains("402");

    if (isSubscriptionError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppTheme.secondaryGold,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ref.tr("select_membership_title"),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRoyalMaroon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ref.tr("select_membership_subtitle"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/plans');
                      },
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: Text(
                        ref.tr("upgrade_membership"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRoyalMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
