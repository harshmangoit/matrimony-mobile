import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/match_item.dart';
import 'api_provider.dart';

class MatchesState {
  final bool isLoading;
  final List<MatchItemModel> matches;
  final String? errorMessage;

  MatchesState({
    this.isLoading = false,
    this.matches = const [],
    this.errorMessage,
  });

  MatchesState copyWith({
    bool? isLoading,
    List<MatchItemModel>? matches,
    String? errorMessage,
  }) {
    return MatchesState(
      isLoading: isLoading ?? this.isLoading,
      matches: matches ?? this.matches,
      errorMessage: errorMessage,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final ApiClient _apiClient;

  MatchesNotifier(this._apiClient) : super(MatchesState());

  Future<void> loadMatches(int childId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.get('/matches?child_id=$childId');
      final list = (resp.data as List).map((x) => MatchItemModel.fromJson(x)).toList();
      state = state.copyWith(matches: list, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final client = ref.watch(apiClientProvider);
  return MatchesNotifier(client);
});
