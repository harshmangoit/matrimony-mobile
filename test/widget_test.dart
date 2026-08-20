import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimony_app/main.dart';
import 'package:matrimony_app/providers/auth_provider.dart';
import 'package:matrimony_app/core/network/api_client.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier() : super(ApiClient()) {
    state = AuthState(isLoading: false, isAuthenticated: false);
  }

  @override
  Future<void> checkInitialAuth() async {
    state = AuthState(isLoading: false, isAuthenticated: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_all_code.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  testWidgets('MatrimonyApp smoke test', (WidgetTester tester) async {
    // Build app with ProviderScope overriding authProvider
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
        child: const MatrimonyApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // Verify MatrimonyApp widget is rendered
    expect(find.byType(MatrimonyApp), findsOneWidget);
  });
}
