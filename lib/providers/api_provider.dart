import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import 'locale_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final locale = ref.watch(localeProvider);
  final client = ApiClient();
  client.dio.options.headers['Accept-Language'] = locale.languageCode;
  return client;
});
