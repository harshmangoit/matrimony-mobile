import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/plan.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

class PaymentState {
  final bool isLoading;
  final List<PlanModel> plans;
  final Map<String, dynamic>? activeSubscription;
  final Map<String, dynamic>? currentRazorpayOrder;
  final String? errorMessage;
  final String? successMessage;

  PaymentState({
    this.isLoading = false,
    this.plans = const [],
    this.activeSubscription,
    this.currentRazorpayOrder,
    this.errorMessage,
    this.successMessage,
  });

  PaymentState copyWith({
    bool? isLoading,
    List<PlanModel>? plans,
    Map<String, dynamic>? activeSubscription,
    Map<String, dynamic>? currentRazorpayOrder,
    String? errorMessage,
    String? successMessage,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      currentRazorpayOrder: currentRazorpayOrder ?? this.currentRazorpayOrder,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final ApiClient _apiClient;
  final Ref _ref;

  PaymentNotifier(this._apiClient, this._ref) : super(PaymentState());

  Future<void> loadPlansAndSubscription() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final plansResp = await _apiClient.dio.get('/plans');
      if (!mounted) return;
      final plansList = (plansResp.data as List).map((x) => PlanModel.fromJson(x)).toList();

      final subResp = await _apiClient.dio.get('/subscription');
      if (!mounted) return;
      
      state = state.copyWith(
        plans: plansList,
        activeSubscription: Map<String, dynamic>.from(subResp.data),
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>?> createOrder(int planId, {int quantity = 1}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resp = await _apiClient.dio.post('/payments/order', data: {
        'plan_id': planId,
        'quantity': quantity,
      });
      if (!mounted) return null;
      final orderData = Map<String, dynamic>.from(resp.data);
      state = state.copyWith(isLoading: false, currentRazorpayOrder: orderData);
      return orderData;
    } on DioException catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      return null;
    }
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final resp = await _apiClient.dio.post('/payments/verify', data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      });
      if (!mounted) return false;

      final msg = resp.data['message']?.toString() ?? 'Subscription activated!';
      await loadPlansAndSubscription();
      try {
        await _ref.read(authProvider.notifier).checkInitialAuth();
      } catch (_) {}
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, successMessage: msg);
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.error.toString());
      return false;
    }
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentNotifier(client, ref);
});
