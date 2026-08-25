import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/profile_visibility.dart';
import '../../providers/children_provider.dart';
import '../../providers/locale_provider.dart';

class VisibilitySettingsScreen extends ConsumerStatefulWidget {
  final int childId;

  const VisibilitySettingsScreen({super.key, required this.childId});

  @override
  ConsumerState<VisibilitySettingsScreen> createState() => _VisibilitySettingsScreenState();
}

class _VisibilitySettingsScreenState extends ConsumerState<VisibilitySettingsScreen> {
  ProfileVisibilityModel? _currentVis;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(childrenProvider.notifier).loadVisibilitySettings(widget.childId);
      final vis = ref.read(childrenProvider).visibilitySettings;
      if (mounted) {
        setState(() {
          _currentVis = vis ?? ProfileVisibilityModel();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final childrenState = ref.watch(childrenProvider);
    final child = childrenState.selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: Text("${ref.tr("visibility_settings")} (${child?.firstName ?? ''})"),
      ),
      body: _currentVis == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.primaryRoyalMaroon, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.tr("privacy_field_control_title"),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.primaryRoyalMaroon,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ref.tr("privacy_field_control_desc"),
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildCategoryTitle(ref.tr("my_candidates")),
                  _buildToggleTile(
                    ref.tr("full_name_label"),
                    ref.tr("visibility_sub_name"),
                    _currentVis!.showName,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showName: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("dob"),
                    ref.tr("visibility_sub_age"),
                    _currentVis!.showAge,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showAge: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("gender"),
                    ref.tr("visibility_sub_gender"),
                    _currentVis!.showGender,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showGender: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("height_cm"),
                    ref.tr("visibility_sub_height"),
                    _currentVis!.showHeight,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showHeight: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("marital_status"),
                    ref.tr("visibility_sub_marital"),
                    _currentVis!.showMaritalStatus,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showMaritalStatus: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("mother_tongue"),
                    ref.tr("visibility_sub_mother_tongue"),
                    _currentVis!.showMotherTongue,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showMotherTongue: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("education_career_sec"),
                    ref.tr("visibility_sub_education"),
                    _currentVis!.showEducation,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showEducation: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("profession"),
                    ref.tr("visibility_sub_profession"),
                    _currentVis!.showProfession,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showProfession: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("family_location_sec"),
                    ref.tr("visibility_sub_location"),
                    _currentVis!.showLocation,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showLocation: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("father_name"),
                    ref.tr("visibility_sub_family"),
                    _currentVis!.showFamily,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showFamily: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("bio_photo_sec"),
                    ref.tr("visibility_sub_photo"),
                    _currentVis!.showPhotos,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showPhotos: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("candidate_bio"),
                    ref.tr("visibility_sub_about"),
                    _currentVis!.showAbout,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showAbout: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("hobbies_interests"),
                    ref.tr("visibility_sub_hobbies"),
                    _currentVis!.showHobbies,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showHobbies: val)),
                  ),
                  _buildToggleTile(
                    ref.tr("lifestyle_values"),
                    ref.tr("visibility_sub_lifestyle"),
                    _currentVis!.showLifestyle,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showLifestyle: val)),
                  ),

                  const SizedBox(height: 24),
                  _buildCategoryTitle(ref.tr("photo_contact_guard_title")),
                  _buildToggleTile(
                    ref.tr("phone_number"),
                    ref.tr("toggle_phone_visibility"),
                    _currentVis!.showPhone,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showPhone: val)),
                    isSensitive: true,
                  ),
                  _buildToggleTile(
                    ref.tr("candidate_email"),
                    ref.tr("toggle_email_visibility"),
                    _currentVis!.showEmail,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showEmail: val)),
                    isSensitive: true,
                  ),
                  _buildToggleTile(
                    ref.tr("city"),
                    ref.tr("visibility_sub_exact_address"),
                    _currentVis!.showExactAddress,
                    (val) => setState(() => _currentVis = _currentVis!.copyWith(showExactAddress: val)),
                    isSensitive: true,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: childrenState.isLoading
                          ? null
                          : () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              final ok = await ref
                                  .read(childrenProvider.notifier)
                                  .updateVisibilitySettings(widget.childId, _currentVis!);
                              if (ok) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text(ref.tr("privacy_updated_success"))),
                                );
                                navigator.pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRoyalMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: childrenState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              ref.tr("save_profile_btn"),
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isSensitive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSensitive && value ? Colors.red.shade700 : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeThumbColor: isSensitive ? Colors.red.shade700 : AppTheme.primaryRoyalMaroon,
        onChanged: onChanged,
      ),
    );
  }
}
