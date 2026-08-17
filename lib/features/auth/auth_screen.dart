import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale.languageCode == 'hi';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5E0B1B),
              Color(0xFF7A1C30),
              Color(0xFF33050E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // High-Contrast Custom Segmented Language Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.secondaryGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8, right: 6),
                            child: Icon(Icons.language_rounded, size: 18, color: AppTheme.secondaryGold),
                          ),
                          _buildLanguageOption(
                            label: "English",
                            isSelected: !isHindi,
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                            },
                          ),
                          _buildLanguageOption(
                            label: "हिंदी",
                            isSelected: isHindi,
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('hi'));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Brand Header Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.secondaryGold.withValues(alpha: 0.6), width: 2),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 40,
                      color: AppTheme.secondaryGold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ref.tr("app_name"),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ref.tr("tagline"),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Trust Badges Row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTrustBadge(Icons.verified_user_rounded, ref.tr("verified_profiles_title")),
                      _buildTrustBadge(Icons.shield_outlined, ref.tr("photo_contact_guard_title")),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Auth Card
                  Card(
                    elevation: 16,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tab Bar Switcher
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.softRoseBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppTheme.primaryRoyalMaroon,
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: AppTheme.textSecondary,
                              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                              tabs: [
                                Tab(height: 40, text: ref.tr("tab_login").toUpperCase()),
                                Tab(height: 40, text: ref.tr("tab_register").toUpperCase()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (authState.errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Dynamic height for TabBarView to fit Login (250px) vs Register (390px)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            height: _tabController.index == 0 ? 250 : 390,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildLoginForm(authState),
                                _buildRegisterForm(authState),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState) {
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            TextFormField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: ref.tr("email_label"),
                hintText: ref.tr("email_hint"),
                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryRoyalMaroon),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Email address is required";
                if (!v.contains("@") || !v.contains(".")) return "Enter a valid email address";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _loginPasswordController,
              obscureText: _obscureLoginPassword,
              decoration: InputDecoration(
                labelText: ref.tr("password_label"),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRoyalMaroon),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? "Password is required" : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        if (_loginFormKey.currentState!.validate()) {
                          ref.read(authProvider.notifier).login(
                                email: _loginEmailController.text.trim(),
                                password: _loginPasswordController.text,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRoyalMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ref.tr("login_btn"),
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(AuthState authState) {
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 4),
            TextFormField(
              controller: _regNameController,
              decoration: InputDecoration(
                labelText: ref.tr("full_name_label"),
                hintText: ref.tr("full_name_hint"),
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryRoyalMaroon),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? "Full name is required" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: ref.tr("email_label"),
                hintText: ref.tr("email_hint"),
                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryRoyalMaroon),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Email is required";
                if (!v.contains("@") || !v.contains(".")) return "Enter a valid email";
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regPasswordController,
              obscureText: _obscureRegPassword,
              decoration: InputDecoration(
                labelText: ref.tr("password_label"),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRoyalMaroon),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) return "Min 6 characters required";
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _regConfirmPasswordController,
              obscureText: _obscureRegConfirmPassword,
              decoration: InputDecoration(
                labelText: ref.tr("confirm_password_label"),
                prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryRoyalMaroon),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
                ),
              ),
              validator: (v) {
                if (v != _regPasswordController.text) return "Passwords do not match";
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        if (_registerFormKey.currentState!.validate()) {
                          ref.read(authProvider.notifier).register(
                                fullName: _regNameController.text.trim(),
                                email: _regEmailController.text.trim(),
                                password: _regPasswordController.text,
                                confirmPassword: _regConfirmPasswordController.text,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRoyalMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ref.tr("register_btn"),
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.secondaryGold, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
