import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';
import '../../providers/locale_provider.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final int candidateId;
  final int childId;

  const MatchDetailScreen({
    super.key,
    required this.candidateId,
    required this.childId,
  });

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _matchDetail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.dio.get(
        '/matches/${widget.candidateId}?child_id=${widget.childId}',
      );
      if (mounted) {
        setState(() {
          _matchDetail = Map<String, dynamic>.from(resp.data);
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.error?.toString() ?? ref.tr("generic_error_msg");
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.tr("call_not_available"))),
      );
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final appTitle = ref.tr("app_name");
    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=Namaste!%20I%20saw%20your%20matrimonial%20profile%20on%20$appTitle.');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.tr("call_not_available"))),
      );
    }
  }

  void _shareProfile(Map<String, dynamic> profile, int score) {
    final name = profile['first_name'] != null ? "${profile['first_name']} ${profile['last_name'] ?? ''}".trim() : "Verified Candidate";
    final age = profile['calculated_age'] != null ? "${profile['calculated_age']} Yrs" : "";
    final edu = profile['highest_education'] ?? '';
    final prof = profile['profession'] ?? '';
    final city = profile['current_city'] ?? '';

    final shareText = '''
🌸 Matrimonial App - Matrimonial Profile Share 🌸

Candidate: $name
Age/Gender: $age ${profile['gender'] ?? ''}
Education: $edu
Profession: $prof
Location: $city
Compatibility Match Score: $score%

Find compatible, verified family matches on Matrimonial app!
''';

    Share.share(shareText, subject: "Matrimonial Profile - $name");
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ref.tr("matched_profile_title"),
          style: const TextStyle(fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_matchDetail != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: ref.tr("share_profile"),
              onPressed: () {
                final profile = Map<String, dynamic>.from(_matchDetail?['visible_profile'] ?? {});
                final score = _matchDetail?['match_score'] ?? 0;
                _shareProfile(profile, score);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorScreen(context, _errorMessage!)
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final profile = Map<String, dynamic>.from(_matchDetail?['visible_profile'] ?? {});
    final score = _matchDetail?['match_score'] ?? 0;
    final breakdown = Map<String, dynamic>.from(_matchDetail?['breakdown'] ?? {});
    final phone = profile['phone_number']?.toString();

    final name = profile.containsKey('first_name')
        ? "${profile['first_name']} ${profile['last_name'] ?? ''}".trim()
        : ref.tr("matched_profile_title");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Responsive Header Card (Prevents word wrap truncation on OnePlus 11 & narrow devices)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.12),
                        child: profile['profile_photo'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(profile['profile_photo'], fit: BoxFit.cover),
                              )
                            : const Icon(Icons.person, size: 34, color: AppTheme.primaryRoyalMaroon),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            () {
                              final ageStr = profile['calculated_age'] != null ? "${profile['calculated_age']} ${ref.tr("age_years")}" : "";
                              final genderStr = profile['gender'] != null ? ref.tr(profile['gender'].toString().toLowerCase()) : "";
                              final headerDetails = [
                                if (ageStr.isNotEmpty) ageStr,
                                if (genderStr.isNotEmpty) genderStr,
                              ].join(" • ");
                              if (headerDetails.isNotEmpty) {
                                return Text(
                                  headerDetails,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                );
                              }
                              return const SizedBox.shrink();
                            }(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRoyalMaroon,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "$score% ${ref.tr("compatibility_match").toUpperCase()}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Contact Actions & Share Section
          Row(
            children: [
              if (phone != null && phone.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(phone),
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: Text(ref.tr("call_now"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(phone),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: Text(ref.tr("whatsapp_chat"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareProfile(profile, score),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: Text(ref.tr("share_profile"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryGold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Compatibility Breakdown Chips
          _buildSectionHeader(ref.tr("compatibility_breakdown")),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: breakdown.entries.map((e) {
              return Chip(
                backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.08),
                side: const BorderSide(color: AppTheme.borderLight),
                label: Text(
                  "${e.key.replaceAll('_score', '').toUpperCase()}: ${e.value}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryRoyalMaroon),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Dynamic Permitted Fields Section
          _buildSectionHeader(ref.tr("verified_matches")),
          const SizedBox(height: 6),
          Text(
            ref.tr("permitted_details_notice"),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          // Render permitted fields dynamically
          _buildDynamicFieldTiles(profile),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryRoyalMaroon,
      ),
    );
  }

  Widget _buildDynamicFieldTiles(Map<String, dynamic> profile) {
    List<Widget> tiles = [];

    void addIfPresent(String key, String label, IconData icon) {
      if (profile.containsKey(key) && profile[key] != null && profile[key].toString().isNotEmpty) {
        tiles.add(
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Icon(icon, color: AppTheme.primaryRoyalMaroon),
              title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              subtitle: Text(
                profile[key].toString(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ),
          ),
        );
      }
    }

    addIfPresent('marital_status', ref.tr("marital_status"), Icons.favorite_border_rounded);
    addIfPresent('mother_tongue', ref.tr("mother_tongue"), Icons.translate_rounded);
    addIfPresent('height_cm', ref.tr("height_cm"), Icons.height_rounded);
    addIfPresent('highest_education', ref.tr("qualification"), Icons.school);
    addIfPresent('profession', ref.tr("profession"), Icons.work);
    addIfPresent('company', ref.tr("company"), Icons.business);
    addIfPresent('current_city', ref.tr("city"), Icons.location_city);
    addIfPresent('state', ref.tr("state"), Icons.map);
    addIfPresent('father_name', ref.tr("father_name"), Icons.family_restroom);
    addIfPresent('about', ref.tr("candidate_bio"), Icons.info_outline);
    addIfPresent('phone_number', ref.tr("phone_number"), Icons.phone);
    addIfPresent('email', ref.tr("candidate_email"), Icons.email);

    if (tiles.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(ref.tr("privacy_hidden_field")),
        ),
      );
    }

    return Column(children: tiles);
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
