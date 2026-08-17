import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/children_provider.dart';
import '../../providers/locale_provider.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  final int? childId;

  const ProfileEditorScreen({super.key, this.childId});

  @override
  ConsumerState<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _motherTongueController;
  late TextEditingController _educationController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _fatherNameController;
  late TextEditingController _aboutController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _photoController;

  String _gender = "Male";
  String _maritalStatus = "Never Married";

  @override
  void initState() {
    super.initState();
    final state = ref.read(childrenProvider);
    final targetChild = widget.childId != null
        ? state.children.firstWhere((c) => c.id == widget.childId, orElse: () => state.selectedChild!)
        : null;

    _firstNameController = TextEditingController(text: targetChild?.firstName ?? "");
    _lastNameController = TextEditingController(text: targetChild?.lastName ?? "");
    _dobController = TextEditingController(text: targetChild?.dateOfBirth ?? "");
    _heightController = TextEditingController(text: targetChild != null && targetChild.heightCm > 0 ? targetChild.heightCm.toString() : "");
    _motherTongueController = TextEditingController(text: targetChild?.motherTongue ?? "");
    _educationController = TextEditingController(text: targetChild?.highestEducation ?? "");
    _professionController = TextEditingController(text: targetChild?.profession ?? "");
    _companyController = TextEditingController(text: targetChild?.company ?? "");
    _cityController = TextEditingController(text: targetChild?.currentCity ?? "");
    _stateController = TextEditingController(text: targetChild?.state ?? "");
    _fatherNameController = TextEditingController(text: targetChild?.fatherName ?? "");
    _aboutController = TextEditingController(text: targetChild?.about ?? "");
    _phoneController = TextEditingController(text: targetChild?.phoneNumber ?? "");
    _emailController = TextEditingController(text: targetChild?.email ?? "");
    _photoController = TextEditingController(text: targetChild?.profilePhoto ?? "");

    if (targetChild != null) {
      if (targetChild.gender.isNotEmpty) _gender = targetChild.gender;
      if (targetChild.maritalStatus.isNotEmpty) _maritalStatus = targetChild.maritalStatus;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _motherTongueController.dispose();
    _educationController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _fatherNameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1998, 1, 1);
    if (_dobController.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text.trim());
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: ref.tr("select_dob_title"),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRoyalMaroon,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch
    final childrenState = ref.watch(childrenProvider);
    final isEditing = widget.childId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? ref.tr("edit_profile_title") : ref.tr("create_profile_title")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 7-DAY EDIT RESTRICTION LOCK BANNER (If locked)
              if (childrenState.editLockMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade300, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          childrenState.editLockMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _buildSectionTitle(ref.tr("personal_info_sec")),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: ref.tr("first_name")),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: ref.tr("last_name")),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _gender,
                      decoration: InputDecoration(labelText: ref.tr("gender")),
                      items: [
                        DropdownMenuItem(value: "Male", child: Text(ref.tr("male"))),
                        DropdownMenuItem(value: "Female", child: Text(ref.tr("female"))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: ref.tr("dob"),
                        hintText: "YYYY-MM-DD",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRoyalMaroon),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ref.tr("height_cm"),
                        hintText: "e.g. 175",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _maritalStatus,
                      decoration: InputDecoration(labelText: ref.tr("marital_status")),
                      items: [
                        DropdownMenuItem(value: "Never Married", child: Text(ref.tr("never_married"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Divorced", child: Text(ref.tr("divorced"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Widowed", child: Text(ref.tr("widowed"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Awaiting Divorce", child: Text(ref.tr("awaiting_divorce"), overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _maritalStatus = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _motherTongueController,
                decoration: InputDecoration(
                  labelText: ref.tr("mother_tongue"),
                  hintText: "e.g. Hindi, Tamil, Bengali, Gujarati",
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("education_career_sec")),
              const SizedBox(height: 12),

              TextFormField(
                controller: _educationController,
                decoration: InputDecoration(
                  labelText: ref.tr("qualification"),
                  hintText: "e.g. B.Tech / M.Tech / MBA / MBBS",
                ),
                validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _professionController,
                      decoration: InputDecoration(
                        labelText: ref.tr("profession"),
                        hintText: "e.g. Engineer",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: ref.tr("company"),
                        hintText: "e.g. Infosys",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("family_location_sec")),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(labelText: ref.tr("city")),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(labelText: ref.tr("state")),
                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  labelText: ref.tr("father_name"),
                  hintText: "e.g. Suresh Sharma",
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("bio_photo_sec")),
              const SizedBox(height: 12),

              // Interactive Candidate Photo Header Card
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryRoyalMaroon, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _buildPhotoAvatar(),
                          ),
                        ),
                        InkWell(
                          onTap: _showPhotoUploadModal,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryRoyalMaroon,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showPhotoUploadModal,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                      label: Text(ref.tr("photo_url"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _aboutController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: ref.tr("candidate_bio"),
                  hintText: "Brief introduction, family background, values and partner expectations...",
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("contact_privacy_sec")),
              const SizedBox(height: 8),
              Text(
                ref.tr("privacy_field_control_desc"),
                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: ref.tr("phone_number")),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: ref.tr("candidate_email")),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: childrenState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final data = {
                              "first_name": _firstNameController.text.trim(),
                              "last_name": _lastNameController.text.trim(),
                              "gender": _gender,
                              "date_of_birth": _dobController.text.trim(),
                              "height_cm": int.tryParse(_heightController.text.trim()) ?? 170,
                              "marital_status": _maritalStatus,
                              "mother_tongue": _motherTongueController.text.trim(),
                              "highest_education": _educationController.text.trim(),
                              "profession": _professionController.text.trim(),
                              "company": _companyController.text.trim(),
                              "current_city": _cityController.text.trim(),
                              "state": _stateController.text.trim(),
                              "father_name": _fatherNameController.text.trim(),
                              "about": _aboutController.text.trim(),
                              "phone_number": _phoneController.text.trim(),
                              "email": _emailController.text.trim(),
                              "profile_photo": _photoController.text.trim(),
                            };

                            bool ok = false;
                            if (isEditing && widget.childId != null) {
                              ok = await ref
                                  .read(childrenProvider.notifier)
                                  .updateChild(widget.childId!, data);
                            } else {
                              ok = await ref
                                  .read(childrenProvider.notifier)
                                  .createChild(data);
                            }

                            if (ok) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text("Matrimonial profile saved successfully!")),
                              );
                              navigator.pop();
                            }
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
                          isEditing ? ref.tr("save_profile_btn") : ref.tr("create_profile_btn"),
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPhotoAvatar() {
    final photoStr = _photoController.text.trim();
    if (photoStr.isEmpty) {
      return Container(
        color: AppTheme.softRoseBackground,
        child: const Icon(Icons.add_a_photo_rounded, size: 36, color: AppTheme.primaryRoyalMaroon),
      );
    }
    if (photoStr.startsWith('data:image')) {
      try {
        final base64Bytes = base64Decode(photoStr.split(',').last);
        return Image.memory(base64Bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Image.network(
      photoStr,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: AppTheme.primaryRoyalMaroon),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
        setState(() {
          _photoController.text = base64Image;
        });
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to pick photo: $e")),
        );
      }
    }
  }

  void _showPhotoUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bContext) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ref.tr("bio_photo_sec"), style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(ref.tr("select_language"), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRoyalMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryGold,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Sample Verified Avatars:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAvatarSampleTile("Groom 1", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300"),
                const SizedBox(width: 8),
                _buildAvatarSampleTile("Bride 1", "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300"),
                const SizedBox(width: 8),
                _buildAvatarSampleTile("Groom 2", "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300"),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSampleTile(String label, String url) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _photoController.text = url;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderLight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, height: 45, width: 45, fit: BoxFit.cover),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
