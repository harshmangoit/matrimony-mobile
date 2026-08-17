import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/children/profile_editor_screen.dart';
import '../../features/children/visibility_settings_screen.dart';
import '../../features/matches/matches_screen.dart';
import '../../features/matches/match_detail_screen.dart';
import '../../features/payments/plans_screen.dart';
import '../../features/payments/checkout_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => authState.isAuthenticated
            ? const DashboardScreen()
            : const AuthScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile-editor',
        builder: (context, state) {
          final childIdStr = state.uri.queryParameters['child_id'];
          final childId = childIdStr != null ? int.tryParse(childIdStr) : null;
          return ProfileEditorScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/visibility-settings',
        builder: (context, state) {
          final childIdStr = state.uri.queryParameters['child_id'];
          final childId = int.parse(childIdStr ?? '0');
          return VisibilitySettingsScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MatchesScreen(),
      ),
      GoRoute(
        path: '/match-detail',
        builder: (context, state) {
          final candidateId = int.parse(state.uri.queryParameters['candidate_id'] ?? '0');
          final childId = int.parse(state.uri.queryParameters['child_id'] ?? '0');
          return MatchDetailScreen(candidateId: candidateId, childId: childId);
        },
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
