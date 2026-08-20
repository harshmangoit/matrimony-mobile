import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../providers/locale_provider.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  final Map<int, int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentProvider.notifier).loadPlansAndSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider); // Global dynamic language watch
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr("nav_plans")),
      ),
      body: paymentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr("select_membership_title"),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRoyalMaroon,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ref.tr("select_membership_subtitle"),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  if (paymentState.plans.isEmpty)
                    Center(child: Text(ref.tr("no_plans_available")))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paymentState.plans.length,
                      itemBuilder: (context, index) {
                        final plan = paymentState.plans[index];
                        return _buildPlanCard(context, plan);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(BuildContext context, plan) {
    final isGold = plan.name.toUpperCase().contains('GOLD') || plan.name.contains('सेलिब्रिटी');
    final isPremium = plan.name.toUpperCase().contains('PREMIUM') || plan.name.contains('वीआईपी');
    final currentQty = _selectedQuantities[plan.id] ?? 1;
    final totalAmount = (plan.priceInr * currentQty).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: (isGold || isPremium) ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isGold
              ? AppTheme.secondaryGold
              : isPremium
                  ? AppTheme.primaryRoyalMaroon
                  : AppTheme.borderLight,
          width: (isGold || isPremium) ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isGold ? Colors.amber.shade900 : AppTheme.primaryRoyalMaroon,
                          ),
                        ),
                      ),
                      if (isGold) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(ref.tr("VIP"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ],
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRoyalMaroon,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(ref.tr("MOST POPULAR"), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "₹$totalAmount",
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRoyalMaroon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${ref.tr("duration_label")}: ${plan.durationDays} ${ref.tr("days_validity")}",
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${ref.tr("category_label")}: ${plan.category}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryRoyalMaroon),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(plan.description, style: const TextStyle(fontSize: 14)),
            const Divider(height: 20),

            // Features List
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(f.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 14),

            // Profile Quantity Selector Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryRoyalMaroon.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr("select_profile_slots_label"),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹${plan.priceInr.toInt()} × $currentQty ${currentQty > 1 ? ref.tr('profiles_unit') : ref.tr('profile_unit')} = ₹$totalAmount",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isGold ? Colors.amber.shade900 : AppTheme.primaryRoyalMaroon,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: currentQty > 1
                                  ? () {
                                      setState(() {
                                        _selectedQuantities[plan.id] = currentQty - 1;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_rounded, size: 20),
                              color: AppTheme.primaryRoyalMaroon,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                "$currentQty",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                setState(() {
                                  _selectedQuantities[plan.id] = currentQty + 1;
                                });
                              },
                              icon: const Icon(Icons.add_rounded, size: 20),
                              color: AppTheme.primaryRoyalMaroon,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final order = await ref
                      .read(paymentProvider.notifier)
                      .createOrder(plan.id, quantity: currentQty);
                  if (order != null) {
                    router.push('/checkout');
                  }
                },
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: Text(
                  ref.tr("subscribe_now"),
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGold ? AppTheme.secondaryGold : AppTheme.primaryRoyalMaroon,
                  foregroundColor: isGold ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
