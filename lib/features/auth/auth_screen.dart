import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
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

                          // Dynamic height for TabBarView to fit Login (340px) vs Register (480px)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            height: _tabController.index == 0 ? 240 : 410,
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

  /*
  Widget _buildGoogleSignInButton(AuthState authState) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.borderLight, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ref.tr("or_divider"),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.borderLight, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: authState.isLoading
                ? null
                : () async {
                    final success = await ref.read(authProvider.notifier).loginWithGoogle();
                    if (success && mounted) {
                      await ref.read(paymentProvider.notifier).loadPlansAndSubscription();
                      final sub = ref.read(paymentProvider).activeSubscription;
                      if (mounted) {
                        if (sub != null && sub['status'] == 'ACTIVE') {
                          context.go('/dashboard');
                        } else {
                          context.go('/plans');
                        }
                      }
                    }
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFDADCE0), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GoogleLogoWidget(size: 20),
                const SizedBox(width: 10),
                Text(
                  ref.tr("google_sign_in"),
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  */

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
                if (v == null || v.trim().isEmpty) return ref.tr("email_required");
                if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(v.trim())) {
                  return ref.tr("email_format_error");
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
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
              validator: (v) => (v == null || v.isEmpty) ? ref.tr("password_required") : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (_loginFormKey.currentState!.validate()) {
                          final success = await ref.read(authProvider.notifier).login(
                                email: _loginEmailController.text.trim(),
                                password: _loginPasswordController.text,
                              );
                          if (success && mounted) {
                            await ref.read(paymentProvider.notifier).loadPlansAndSubscription();
                            final sub = ref.read(paymentProvider).activeSubscription;
                            if (mounted) {
                              if (sub != null && sub['status'] == 'ACTIVE') {
                                context.go('/dashboard');
                              } else {
                                context.go('/plans');
                              }
                            }
                          }
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
            // Google Sign-In button hidden as requested
            // _buildGoogleSignInButton(authState),
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
              validator: (v) => (v == null || v.trim().isEmpty) ? ref.tr("full_name_required") : null,
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
                if (v == null || v.trim().isEmpty) return ref.tr("email_required");
                if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(v.trim())) {
                  return ref.tr("email_format_error");
                }
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
                if (v == null || v.length < 6) return ref.tr("min_password_length_error");
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
                if (v != _regPasswordController.text) return ref.tr("passwords_dont_match_error");
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
                    : () async {
                        if (_registerFormKey.currentState!.validate()) {
                          final regEmail = _regEmailController.text.trim();
                          final success = await ref.read(authProvider.notifier).register(
                                fullName: _regNameController.text.trim(),
                                email: regEmail,
                                password: _regPasswordController.text,
                                confirmPassword: _regConfirmPasswordController.text,
                              );
                          if (success && mounted) {
                            _loginEmailController.text = regEmail;
                            _regPasswordController.clear();
                            _regConfirmPasswordController.clear();
                            _tabController.animateTo(0);

                            await ref.read(paymentProvider.notifier).loadPlansAndSubscription();
                            if (mounted) {
                              context.go('/plans');
                            }
                          }
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
            // Google Sign-In button hidden as requested
            // _buildGoogleSignInButton(authState),
          ],
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

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, stack) => Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: Color(0xFF4285F4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          "G",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
