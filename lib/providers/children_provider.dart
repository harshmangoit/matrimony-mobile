import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/child_profile.dart';
import '../models/profile_visibility.dart';
import 'api_provider.dart';

class ChildrenState {
  final bool isLoading;
  final List<ChildProfileModel> children;
  final ChildProfileModel? selectedChild;
  final ProfileVisibilityModel? visibilitySettings;
  final String? errorMessage;
  final String? editLockMessage; // For 7-day edit restriction lock alert

  ChildrenState({
    this.isLoading = false,
    this.children = const [],
    this.selectedChild,
    this.visibilitySettings,
    this.errorMessage,
    this.editLockMessage,
  });

  ChildrenState copyWith({
    bool? isLoading,
    List<ChildProfileModel>? children,
    ChildProfileModel? selectedChild,
    ProfileVisibilityModel? visibilitySettings,
    String? errorMessage,
    String? editLockMessage,
  }) {
    return ChildrenState(
      isLoading: isLoading ?? this.isLoading,
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      visibilitySettings: visibilitySettings ?? this.visibilitySettings,
      errorMessage: errorMessage,
      editLockMessage: editLockMessage,
    );
  }
}

class ChildrenNotifier extends StateNotifier<ChildrenState> {
  final ApiClient _apiClient;

  ChildrenNotifier(this._apiClient) : super(ChildrenState());

  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.get('/children');
      if (!mounted) return;
      final list = (resp.data as List).map((x) => ChildProfileModel.fromJson(x)).toList();
      
      final currentSelected = state.selectedChild != null && list.any((c) => c.id == state.selectedChild!.id)
          ? list.firstWhere((c) => c.id == state.selectedChild!.id)
          : (list.isNotEmpty ? list.first : null);

      state = state.copyWith(
        children: list,
        selectedChild: currentSelected,
        isLoading: false,
      );

      if (currentSelected != null) {
        await loadVisibilitySettings(currentSelected.id);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectChild(ChildProfileModel child) {
    state = state.copyWith(selectedChild: child);
    loadVisibilitySettings(child.id);
  }

  Future<bool> createChild(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.post('/children', data: data);
      if (!mounted) return false;
      final newChild = ChildProfileModel.fromJson(resp.data);
      await loadChildren();
      if (!mounted) return false;
      selectChild(newChild);
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      return false;
    }
  }

  Future<bool> updateChild(int childId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null, editLockMessage: null);
    try {
      final resp = await _apiClient.dio.put('/children/$childId', data: data);
      if (!mounted) return false;
      final updated = ChildProfileModel.fromJson(resp.data);
      await loadChildren();
      if (!mounted) return false;
      selectChild(updated);
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      if (e.response?.statusCode == 403) {
        // 7-DAY EDIT LOCK EXCEPTION!
        final msg = e.response?.data['detail']?.toString() ?? e.error.toString();
        state = state.copyWith(isLoading: false, editLockMessage: msg);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      }
      return false;
    }
  }

  Future<bool> toggleChildStatus(int childId, String newStatus) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _apiClient.dio.patch('/children/$childId/status', data: {
        'status': newStatus,
      });
      if (!mounted) return false;
      await loadChildren();
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      return false;
    }
  }

  Future<void> loadVisibilitySettings(int childId) async {
    try {
      final resp = await _apiClient.dio.get('/children/$childId/visibility');
      if (!mounted) return;
      final vis = ProfileVisibilityModel.fromJson(resp.data);
      state = state.copyWith(visibilitySettings: vis);
    } catch (_) {}
  }

  Future<bool> updateVisibilitySettings(int childId, ProfileVisibilityModel vis) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.put('/children/$childId/visibility', data: vis.toJson());
      if (!mounted) return false;
      final updatedVis = ProfileVisibilityModel.fromJson(resp.data);
      state = state.copyWith(visibilitySettings: updatedVis, isLoading: false);
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      return false;
    }
  }
}

final childrenProvider = StateNotifierProvider<ChildrenNotifier, ChildrenState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ChildrenNotifier(client);
});
