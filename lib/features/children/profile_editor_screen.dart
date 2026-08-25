import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_theme.dart';
import '../../core/constants/indian_data_constants.dart';
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
  final stt.SpeechToText _speech = stt.SpeechToText();

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

  late TextEditingController _gotraSelfController;
  late TextEditingController _gotraMamaController;
  late TextEditingController _gotraPaternalNaniController;
  late TextEditingController _gotraMaternalNaniController;
  late TextEditingController _weightController;
  late TextEditingController _motherNameController;
  late TextEditingController _grandfatherNameController;
  late TextEditingController _siblingsController;
  late TextEditingController _familyMembersController;
  late TextEditingController _familyBackgroundController;
  late TextEditingController _tehsilController;
  late TextEditingController _villageTownController;
  late TextEditingController _postOfficeController;
  late TextEditingController _pincodeController;
  late TextEditingController _birthTimeController;

  final _firstNameKey = GlobalKey<FormFieldState>();
  final _lastNameKey = GlobalKey<FormFieldState>();
  final _dobKey = GlobalKey<FormFieldState>();
  final _heightKey = GlobalKey<FormFieldState>();
  final _weightKey = GlobalKey<FormFieldState>();
  final _pincodeKey = GlobalKey<FormFieldState>();
  final _familyMembersKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();

  String _gender = "Male";
  String _maritalStatus = "Never Married";
  String _complexion = "Fair";
  String _searchType = "Engagement";
  String _manglikStatus = "Normal";

  void _scrollToFirstError() {
    final keysInOrder = [
      _firstNameKey,
      _lastNameKey,
      _dobKey,
      _heightKey,
      _weightKey,
      _pincodeKey,
      _familyMembersKey,
      _phoneKey,
      _emailKey,
    ];

    for (final key in keysInOrder) {
      if (key.currentState?.hasError == true && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.15,
        );
        break;
      }
    }
  }

  String _normalizeComplexion(String? val) {
    if (val == null || val.trim().isEmpty) return "Fair";
    final v = val.trim();
    if (v == "गोरा" || v.toLowerCase() == "fair") return "Fair";
    if (v == "गेहुँआ" || v.toLowerCase() == "wheatish") return "Wheatish";
    if (v == "साँवला" || v.toLowerCase() == "dark") return "Dark";
    return "Fair";
  }

  String _normalizeGender(String? val) {
    if (val == null || val.trim().isEmpty) return "Male";
    final v = val.trim().toLowerCase();
    if (v == "female" || v == "महिला") return "Female";
    return "Male";
  }

  String _normalizeMaritalStatus(String? val) {
    if (val == null || val.trim().isEmpty) return "Never Married";
    final v = val.trim();
    if (v.contains("Divorced") || v.contains("तलाकशुदा")) return "Divorced";
    if (v.contains("Widowed") || v.contains("विधवा") || v.contains("विधुर")) return "Widowed";
    if (v.contains("Awaiting") || v.contains("विचाराधीन") || v.contains("विचारणीय") || v.contains("प्रतीक्षा")) return "Awaiting Divorce";
    return "Never Married";
  }

  String _normalizeSearchType(String? val) {
    if (val == null || val.trim().isEmpty) return "Engagement";
    final v = val.trim();
    if (v.contains("Remarriage") || v.contains("पुनर्विवाह")) return "Remarriage";
    return "Engagement";
  }

  String _normalizeManglikStatus(String? val) {
    if (val == null || val.trim().isEmpty) return "Normal";
    final v = val.trim();
    if (v.toLowerCase().contains("anshik") || v.contains("आंशिक")) return "Anshik";
    if (v.toLowerCase().contains("manglik") || v.contains("मांगलिक")) return "Manglik";
    return "Normal";
  }

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
    _motherTongueController = TextEditingController(text: IndianDataConstants.formatValue(targetChild?.motherTongue, _isHindi));
    _educationController = TextEditingController(text: IndianDataConstants.formatValue(targetChild?.highestEducation, _isHindi));
    _professionController = TextEditingController(text: IndianDataConstants.formatValue(targetChild?.profession, _isHindi));
    _companyController = TextEditingController(text: targetChild?.company ?? "");
    _cityController = TextEditingController(text: IndianDataConstants.formatValue(targetChild?.currentCity, _isHindi));
    _stateController = TextEditingController(text: IndianDataConstants.formatValue(targetChild?.state, _isHindi));
    _fatherNameController = TextEditingController(text: targetChild?.fatherName ?? "");
    _aboutController = TextEditingController(text: targetChild?.about ?? "");
    _phoneController = TextEditingController(text: targetChild?.phoneNumber ?? "");
    _emailController = TextEditingController(text: targetChild?.email ?? "");
    _photoController = TextEditingController(text: targetChild?.profilePhoto ?? "");

    _gotraSelfController = TextEditingController(text: targetChild?.gotraSelf ?? "");
    _gotraMamaController = TextEditingController(text: targetChild?.gotraMama ?? "");
    _gotraPaternalNaniController = TextEditingController(text: targetChild?.gotraPaternalNani ?? "");
    _gotraMaternalNaniController = TextEditingController(text: targetChild?.gotraMaternalNani ?? "");
    _weightController = TextEditingController(text: targetChild != null && targetChild.weightKg != null ? targetChild.weightKg.toString() : "");
    _motherNameController = TextEditingController(text: targetChild?.motherName ?? "");
    _grandfatherNameController = TextEditingController(text: targetChild?.grandfatherName ?? "");
    _siblingsController = TextEditingController(text: targetChild?.siblings ?? "");
    _familyMembersController = TextEditingController(text: targetChild != null && targetChild.familyMembersCount != null ? targetChild.familyMembersCount.toString() : "");
    _familyBackgroundController = TextEditingController(text: targetChild?.familyBackground ?? "");
    _tehsilController = TextEditingController(text: targetChild?.tehsil ?? "");
    _villageTownController = TextEditingController(text: targetChild?.villageTown ?? "");
    _postOfficeController = TextEditingController(text: targetChild?.postOffice ?? "");
    _pincodeController = TextEditingController(text: targetChild?.pincode ?? "");
    _birthTimeController = TextEditingController(text: targetChild?.birthTime ?? "");

    if (targetChild != null) {
      _gender = _normalizeGender(targetChild.gender);
      _maritalStatus = _normalizeMaritalStatus(targetChild.maritalStatus);
      _complexion = _normalizeComplexion(targetChild.complexion);
      _searchType = _normalizeSearchType(targetChild.searchType);
      _manglikStatus = _normalizeManglikStatus(targetChild.manglikStatus);
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

    _gotraSelfController.dispose();
    _gotraMamaController.dispose();
    _gotraPaternalNaniController.dispose();
    _gotraMaternalNaniController.dispose();
    _weightController.dispose();
    _motherNameController.dispose();
    _grandfatherNameController.dispose();
    _siblingsController.dispose();
    _familyMembersController.dispose();
    _familyBackgroundController.dispose();
    _tehsilController.dispose();
    _villageTownController.dispose();
    _postOfficeController.dispose();
    _pincodeController.dispose();
    _birthTimeController.dispose();
    super.dispose();
  }

  bool get _isHindi => ref.read(localeProvider).languageCode == 'hi';

  List<String> get _motherTongues => IndianDataConstants.getMotherTongues(_isHindi);
  List<String> get _educationOptions => IndianDataConstants.getEducationOptions(_isHindi);
  List<String> get _professions => IndianDataConstants.getProfessionOptions(_isHindi);

  Future<void> _selectState() async {
    final oldState = _stateController.text;
    await _showSearchablePicker(
      context: context,
      title: ref.tr("state"),
      options: IndianDataConstants.getStates(_isHindi),
      controller: _stateController,
    );
    if (_stateController.text != oldState) {
      final availableCities = IndianDataConstants.getCitiesForState(_stateController.text, _isHindi);
      if (!availableCities.contains(_cityController.text)) {
        setState(() {
          _cityController.text = "";
        });
      }
    }
  }

  Future<void> _selectCity() async {
    if (_stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.tr("select_state_first_prompt")),
          duration: const Duration(seconds: 3),
          backgroundColor: AppTheme.primaryRoyalMaroon,
        ),
      );
      return;
    }
    final cities = IndianDataConstants.getCitiesForState(_stateController.text, _isHindi);
    await _showSearchablePicker(
      context: context,
      title: ref.tr("city"),
      options: cities,
      controller: _cityController,
    );
  }

  Future<void> _showSearchablePicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) async {
    String searchQuery = "";
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final filtered = options.where((opt) {
              return opt.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRoyalMaroon),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: ref.tr("search_placeholder"),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRoyalMaroon),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (val) {
                        setPickerState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Column(
                        children: [
                          if (searchQuery.trim().isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.add_circle_outline, color: AppTheme.primaryRoyalMaroon),
                              title: Text("${ref.tr("custom_option")}: '${searchQuery.trim()}'"),
                              onTap: () {
                                setState(() {
                                  controller.text = searchQuery.trim();
                                });
                                Navigator.pop(ctx);
                              },
                            ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final isSelected = controller.text == item;
                                return ListTile(
                                  title: Text(item, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryRoyalMaroon) : null,
                                  onTap: () {
                                    setState(() {
                                      controller.text = item;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final minAgeYears = _gender == "Female" ? 18 : 21;
    final maxAllowedDate = DateTime(now.year - minAgeYears, now.month, now.day);

    DateTime initialDate = DateTime(1998, 1, 1);
    if (_dobController.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text.trim());
      } catch (_) {}
    }
    if (initialDate.isAfter(maxAllowedDate)) {
      initialDate = maxAllowedDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: maxAllowedDate,
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

  Future<void> _startVoiceInput(TextEditingController controller, String fieldName) async {
    bool available = false;
    bool isListening = false;
    String textResult = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void handleSpeechError(dynamic error) {
              final errStr = error.toString();
              debugPrint('Speech recognition error: $errStr');
              setModalState(() {
                isListening = false;
                if (errStr.contains("error_permission")) {
                  textResult = ref.tr("microphone_permission_error");
                } else if (errStr.contains("error_speech_timeout") || errStr.contains("error_no_match")) {
                  textResult = ref.tr("speech_no_match_error");
                } else if (errStr.contains("error_service_unavailable")) {
                  textResult = ref.tr("speech_service_unavailable_error");
                } else {
                  textResult = ref.tr("voice_unavailable_error");
                }
              });
            }

            void startListening() async {
              try {
                available = await _speech.initialize(
                  onStatus: (status) {
                    debugPrint('Speech status: $status');
                    if (status == 'done' || status == 'notListening') {
                      setModalState(() => isListening = false);
                    }
                  },
                  onError: (errorNotification) => handleSpeechError(errorNotification),
                );
              } catch (e) {
                available = false;
                handleSpeechError(e);
                return;
              }

              if (available) {
                setModalState(() {
                  isListening = true;
                  textResult = "";
                });
                try {
                  await _speech.listen(
                    listenOptions: stt.SpeechListenOptions(
                      localeId: ref.read(localeProvider).languageCode == 'hi' ? 'hi-IN' : 'en-US',
                      listenFor: const Duration(seconds: 30),
                      pauseFor: const Duration(seconds: 4),
                    ),
                    onResult: (val) {
                      setModalState(() {
                        textResult = val.recognizedWords;
                      });
                    },
                  );
                } catch (e) {
                  handleSpeechError(e);
                }
              } else {
                setModalState(() {
                  isListening = false;
                  textResult = ref.tr("voice_unavailable_error");
                });
              }
            }

            void stopListening() {
              if (_speech.isListening) {
                _speech.stop();
              }
              setModalState(() {
                isListening = false;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "${ref.tr("voice_input_for")} $fieldName",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      textResult.isEmpty
                          ? (isListening ? ref.tr("listening_voice") : ref.tr("tap_mic_to_speak"))
                          : textResult,
                      style: TextStyle(
                        fontSize: 14,
                        color: textResult.isEmpty ? Colors.grey : Colors.black,
                        fontStyle: textResult.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: isListening ? stopListening : startListening,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: isListening ? Colors.red.shade100 : AppTheme.primaryRoyalMaroon.withValues(alpha: 0.1),
                      child: Icon(
                        isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: isListening ? Colors.red : AppTheme.primaryRoyalMaroon,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isListening ? ref.tr("listening_status") : ref.tr("tap_to_speak_status"),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (isListening) stopListening();
                            Navigator.pop(context);
                          },
                          child: Text(ref.tr("cancel_btn")),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isListening) stopListening();
                            if (textResult.isNotEmpty &&
                                textResult != ref.tr("listening_voice") &&
                                textResult != ref.tr("voice_unavailable_error")) {
                              controller.text = textResult;
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRoyalMaroon,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(ref.tr("save_btn")),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch
    final childrenState = ref.watch(childrenProvider);
    final isEditing = widget.childId != null;

    final targetChild = widget.childId != null
        ? childrenState.children.firstWhere((c) => c.id == widget.childId, orElse: () => childrenState.selectedChild!)
        : null;

    bool isProfileLocked = childrenState.editLockMessage != null;
    if (targetChild?.createdAt != null) {
      final lockExpiry = targetChild!.createdAt!.add(const Duration(days: 7));
      if (DateTime.now().isAfter(lockExpiry)) {
        isProfileLocked = true;
      }
    }

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
              if (isProfileLocked) ...[
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
                          childrenState.editLockMessage ?? ref.tr("locked_profile"),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              AbsorbPointer(
                absorbing: isProfileLocked,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(ref.tr("personal_info_sec")),
                    const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _firstNameKey,
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: ref.tr("first_name"),
                        errorMaxLines: 3,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_firstNameController, ref.tr("first_name")),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? ref.tr("field_required") : v.trim().length < 2 ? ref.tr("name_min_length_error") : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: _lastNameKey,
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: ref.tr("last_name"),
                        errorMaxLines: 3,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_lastNameController, ref.tr("last_name")),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? ref.tr("field_required") : v.trim().length < 2 ? ref.tr("name_min_length_error") : null,
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
                      initialValue: ["Male", "Female"].contains(_gender) ? _gender : "Male",
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
                      key: _dobKey,
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: ref.tr("dob"),
                        hintText: "YYYY-MM-DD",
                        errorMaxLines: 3,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRoyalMaroon),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return ref.tr("field_required");
                        try {
                          final picked = DateTime.parse(v.trim());
                          final now = DateTime.now();
                          if (picked.isAfter(now)) return ref.tr("dob_future_error");
                          final minAgeYears = _gender == "Female" ? 18 : 21;
                          final maxLegalDOB = DateTime(now.year - minAgeYears, now.month, now.day);
                          if (picked.isAfter(maxLegalDOB)) {
                            final genderLabel = _gender == "Female" ? ref.tr("female") : ref.tr("male");
                            return "${ref.tr('candidate_underage_error')} (${ref.tr('min_age_label')} $minAgeYears ${ref.tr('years_for')} $genderLabel)";
                          }
                          final age = (now.difference(picked).inDays / 365.25).floor();
                          if (age > 100) return ref.tr("dob_invalid_error");
                        } catch (_) {
                          return ref.tr("dob_format_error");
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _heightKey,
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ref.tr("height_cm"),
                        hintText: ref.tr("hint_height"),
                        errorMaxLines: 3,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final h = int.tryParse(v.trim());
                          if (h == null || h < 90 || h > 250) return ref.tr("height_range_error");
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: ["Never Married", "Divorced", "Widowed", "Awaiting Divorce"].contains(_maritalStatus) ? _maritalStatus : "Never Married",
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
                readOnly: true,
                onTap: () => _showSearchablePicker(
                  context: context,
                  title: ref.tr("mother_tongue"),
                  options: _motherTongues,
                  controller: _motherTongueController,
                ),
                decoration: InputDecoration(
                  labelText: ref.tr("mother_tongue"),
                  hintText: ref.tr("hint_mother_tongue"),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.primaryRoyalMaroon),
                        onPressed: () => _showSearchablePicker(
                          context: context,
                          title: ref.tr("mother_tongue"),
                          options: _motherTongues,
                          controller: _motherTongueController,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.grey),
                        onPressed: () => _startVoiceInput(_motherTongueController, ref.tr("mother_tongue")),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: ["Engagement", "Remarriage"].contains(_searchType) ? _searchType : "Engagement",
                      decoration: InputDecoration(labelText: ref.tr("search_type")),
                      items: [
                        DropdownMenuItem(value: "Engagement", child: Text(ref.tr("search_type_engagement"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Remarriage", child: Text(ref.tr("search_type_remarriage"), overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _searchType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: ["Normal", "Manglik", "Anshik"].contains(_manglikStatus) ? _manglikStatus : "Normal",
                      decoration: InputDecoration(labelText: ref.tr("manglik_status")),
                      items: [
                        DropdownMenuItem(value: "Normal", child: Text(ref.tr("manglik_status_normal"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Manglik", child: Text(ref.tr("manglik_status_manglik"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Anshik", child: Text(ref.tr("manglik_status_anshik"), overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _manglikStatus = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _weightKey,
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final w = double.tryParse(v.trim());
                          if (w == null || w < 30 || w > 200) return ref.tr("weight_range_error");
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: ref.tr("weight_kg"),
                        hintText: ref.tr("hint_weight"),
                        errorMaxLines: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: ["Fair", "Wheatish", "Dark"].contains(_complexion) ? _complexion : "Fair",
                      decoration: InputDecoration(labelText: ref.tr("complexion")),
                      items: [
                        DropdownMenuItem(value: "Fair", child: Text(ref.tr("complexion_fair"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Wheatish", child: Text(ref.tr("complexion_wheatish"), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: "Dark", child: Text(ref.tr("complexion_dark"), overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _complexion = val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("education_career_sec")),
              const SizedBox(height: 12),

              TextFormField(
                controller: _educationController,
                readOnly: true,
                onTap: () => _showSearchablePicker(
                  context: context,
                  title: ref.tr("qualification"),
                  options: _educationOptions,
                  controller: _educationController,
                ),
                decoration: InputDecoration(
                  labelText: ref.tr("qualification"),
                  hintText: ref.tr("hint_education"),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.primaryRoyalMaroon),
                        onPressed: () => _showSearchablePicker(
                          context: context,
                          title: ref.tr("qualification"),
                          options: _educationOptions,
                          controller: _educationController,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.grey),
                        onPressed: () => _startVoiceInput(_educationController, ref.tr("qualification")),
                      ),
                    ],
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? ref.tr("field_required") : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _professionController,
                      readOnly: true,
                      onTap: () => _showSearchablePicker(
                        context: context,
                        title: ref.tr("profession"),
                        options: _professions,
                        controller: _professionController,
                      ),
                      decoration: InputDecoration(
                        labelText: ref.tr("profession"),
                        hintText: ref.tr("hint_profession"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.primaryRoyalMaroon),
                          onPressed: () => _showSearchablePicker(
                            context: context,
                            title: ref.tr("profession"),
                            options: _professions,
                            controller: _professionController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: ref.tr("company"),
                        hintText: ref.tr("hint_company"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_companyController, ref.tr("company")),
                        ),
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
                      controller: _stateController,
                      readOnly: true,
                      onTap: _selectState,
                      decoration: InputDecoration(
                        labelText: ref.tr("state"),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.primaryRoyalMaroon),
                              onPressed: _selectState,
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.grey),
                              onPressed: () => _startVoiceInput(_stateController, ref.tr("state")),
                            ),
                          ],
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? ref.tr("field_required") : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      readOnly: true,
                      onTap: _selectCity,
                      decoration: InputDecoration(
                        labelText: ref.tr("city"),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppTheme.primaryRoyalMaroon),
                              onPressed: _selectCity,
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.grey),
                              onPressed: () => _startVoiceInput(_cityController, ref.tr("city")),
                            ),
                          ],
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? ref.tr("field_required") : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tehsilController,
                      decoration: InputDecoration(
                        labelText: ref.tr("tehsil"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_tehsilController, ref.tr("tehsil")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _villageTownController,
                      decoration: InputDecoration(
                        labelText: ref.tr("village_town"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_villageTownController, ref.tr("village_town")),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postOfficeController,
                      decoration: InputDecoration(
                        labelText: ref.tr("post_office"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_postOfficeController, ref.tr("post_office")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: _pincodeKey,
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ref.tr("pincode"),
                        errorMaxLines: 3,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          if (!RegExp(r"^[1-9][0-9]{5}$").hasMatch(v.trim())) {
                            return ref.tr("pincode_format_error");
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("family_details_sec")),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatherNameController,
                      decoration: InputDecoration(
                        labelText: ref.tr("father_name"),
                        hintText: ref.tr("hint_father_name"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_fatherNameController, ref.tr("father_name")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _grandfatherNameController,
                      decoration: InputDecoration(
                        labelText: ref.tr("grandfather_name"),
                        hintText: ref.tr("hint_grandfather_name"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_grandfatherNameController, ref.tr("grandfather_name")),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _motherNameController,
                      decoration: InputDecoration(
                        labelText: ref.tr("mother_name"),
                        hintText: ref.tr("hint_mother_name"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_motherNameController, ref.tr("mother_name")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: _familyMembersKey,
                      controller: _familyMembersController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ref.tr("family_members_count"),
                        hintText: ref.tr("hint_family_members"),
                        errorMaxLines: 3,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          final cnt = int.tryParse(v.trim());
                          if (cnt == null || cnt < 1 || cnt > 30) {
                            return ref.tr("family_count_error");
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _siblingsController,
                decoration: InputDecoration(
                  labelText: ref.tr("siblings_details"),
                  hintText: ref.tr("hint_siblings"),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey),
                    onPressed: () => _startVoiceInput(_siblingsController, ref.tr("siblings_details")),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _familyBackgroundController,
                decoration: InputDecoration(
                  labelText: ref.tr("family_background"),
                  hintText: ref.tr("hint_family_bg"),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey),
                    onPressed: () => _startVoiceInput(_familyBackgroundController, ref.tr("family_background")),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gotraSelfController,
                      decoration: InputDecoration(
                        labelText: ref.tr("gotra_self"),
                        hintText: ref.tr("hint_gotra_self"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_gotraSelfController, ref.tr("gotra_self")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gotraMamaController,
                      decoration: InputDecoration(
                        labelText: ref.tr("gotra_mama"),
                        hintText: ref.tr("hint_gotra_mama"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_gotraMamaController, ref.tr("gotra_mama")),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gotraPaternalNaniController,
                      decoration: InputDecoration(
                        labelText: ref.tr("gotra_dadi"),
                        hintText: ref.tr("hint_gotra_dadi"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_gotraPaternalNaniController, ref.tr("gotra_dadi")),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gotraMaternalNaniController,
                      decoration: InputDecoration(
                        labelText: ref.tr("gotra_nani"),
                        hintText: ref.tr("hint_gotra_nani"),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () => _startVoiceInput(_gotraMaternalNaniController, ref.tr("gotra_nani")),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  hintText: ref.tr("hint_bio"),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey),
                    onPressed: () => _startVoiceInput(_aboutController, ref.tr("candidate_bio")),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(ref.tr("contact_privacy_sec")),
              const SizedBox(height: 12),

              if (isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/visibility-settings?child_id=${widget.childId}');
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: Text(ref.tr("configure_privacy_btn")),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _phoneKey,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: ref.tr("phone_number"),
                        hintText: ref.tr("hint_phone"),
                        errorMaxLines: 3,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          if (!RegExp(r"^[6-9][0-9]{9}$").hasMatch(v.trim())) {
                            return ref.tr("phone_format_error");
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: _emailKey,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: ref.tr("candidate_email"),
                        hintText: ref.tr("hint_email"),
                        errorMaxLines: 3,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(v.trim())) {
                            return ref.tr("email_format_error");
                          }
                        }
                        return null;
                      },
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
                  onPressed: (childrenState.isLoading || isProfileLocked)
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            _scrollToFirstError();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ref.tr("form_validation_error_prompt")),
                                backgroundColor: AppTheme.accentCrimson,
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

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
                              "tehsil": _tehsilController.text.trim(),
                              "village_town": _villageTownController.text.trim(),
                              "post_office": _postOfficeController.text.trim(),
                              "pincode": _pincodeController.text.trim(),
                              "father_name": _fatherNameController.text.trim(),
                              "grandfather_name": _grandfatherNameController.text.trim(),
                              "mother_name": _motherNameController.text.trim(),
                              "siblings": _siblingsController.text.trim(),
                              "family_members_count": int.tryParse(_familyMembersController.text.trim()),
                              "family_background": _familyBackgroundController.text.trim(),
                              "birth_time": _birthTimeController.text.trim(),
                              "about": _aboutController.text.trim(),
                              "phone_number": _phoneController.text.trim(),
                              "email": _emailController.text.trim(),
                              "profile_photo": _photoController.text.trim(),
                              "category": targetChild?.category ?? "A",
                              "search_type": _searchType,
                              "manglik_status": _manglikStatus,
                              "weight_kg": double.tryParse(_weightController.text.trim()),
                              "complexion": _complexion,
                              "gotra_self": _gotraSelfController.text.trim(),
                              "gotra_mama": _gotraMamaController.text.trim(),
                              "gotra_paternal_nani": _gotraPaternalNaniController.text.trim(),
                              "gotra_maternal_nani": _gotraMaternalNaniController.text.trim(),
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
                            if (!context.mounted) return;

                            if (ok) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(ref.tr("profile_saved_success")),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              navigator.pop();
                            } else {
                              final err = ref.read(childrenProvider).errorMessage ?? ref.tr("generic_error_msg");
                              final lowerErr = err.toLowerCase();
                              if (lowerErr.contains('capacity') || lowerErr.contains('limit') || lowerErr.contains('क्षमता') || lowerErr.contains('सीमा')) {
                                showDialog(
                                  context: context,
                                  builder: (dlgContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: Row(
                                      children: [
                                        const Icon(Icons.lock_rounded, color: Colors.orange, size: 26),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            ref.tr("slot_limit_reached_title"),
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(err),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dlgContext).pop(),
                                        child: Text(ref.tr("cancel_btn")),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(dlgContext).pop();
                                          context.push('/plans');
                                        },
                                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                        label: Text(ref.tr("buy_additional_slot_btn")),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryRoyalMaroon,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(err),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
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
          SnackBar(content: Text("${ref.tr("photo_pick_error")}: $e")),
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(ref.tr("camera_btn")),
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
                    label: Text(ref.tr("gallery_btn")),
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
            Text(ref.tr("sample_avatars_title"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAvatarSampleTile(ref.tr("groom_1"), "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300"),
                const SizedBox(width: 8),
                _buildAvatarSampleTile(ref.tr("bride_1"), "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300"),
                const SizedBox(width: 8),
                _buildAvatarSampleTile(ref.tr("groom_2"), "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300"),
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
