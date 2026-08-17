import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/api_provider.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Matched Matrimonial Profile"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final profile = Map<String, dynamic>.from(_matchDetail?['visible_profile'] ?? {});
    final score = _matchDetail?['match_score'] ?? 0;
    final breakdown = Map<String, dynamic>.from(_matchDetail?['breakdown'] ?? {});

    final name = profile.containsKey('first_name')
        ? "${profile['first_name']} ${profile['last_name'] ?? ''}".trim()
        : "Verified Matrimonial Profile";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.12),
                    child: profile['profile_photo'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(profile['profile_photo'], fit: BoxFit.cover),
                          )
                        : const Icon(Icons.person, size: 36, color: AppTheme.primaryRoyalMaroon),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (profile['calculated_age'] != null)
                          Text(
                            "${profile['calculated_age']} Yrs • ${profile['gender'] ?? ''}",
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRoyalMaroon,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      "$score% MATCH",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Compatibility Breakdown Chips
          _buildSectionHeader("Compatibility Breakdown"),
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
          _buildSectionHeader("Permitted Profile Details"),
          const SizedBox(height: 6),
          const Text(
            "Notice: Below fields represent only the individual details permitted by the profile owner under field-level privacy settings.",
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          // Render permitted fields dynamically (omit private fields!)
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

    addIfPresent('highest_education', 'Education Qualification', Icons.school);
    addIfPresent('profession', 'Profession', Icons.work);
    addIfPresent('company', 'Employer / Company', Icons.business);
    addIfPresent('current_city', 'Current City', Icons.location_city);
    addIfPresent('state', 'State', Icons.map);
    addIfPresent('country', 'Country', Icons.flag);
    addIfPresent('father_name', 'Father Name', Icons.family_restroom);
    addIfPresent('mother_name', 'Mother Name', Icons.family_restroom);
    addIfPresent('about', 'About Candidate', Icons.info_outline);
    addIfPresent('hobbies', 'Hobbies', Icons.palette);
    addIfPresent('lifestyle', 'Lifestyle', Icons.style);
    addIfPresent('phone_number', 'Phone Number (Owner Authorized)', Icons.phone);
    addIfPresent('email', 'Email Address (Owner Authorized)', Icons.email);
    addIfPresent('exact_address', 'Exact Address (Owner Authorized)', Icons.home);

    if (tiles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No additional public details enabled by owner."),
        ),
      );
    }

    return Column(children: tiles);
  }
}
