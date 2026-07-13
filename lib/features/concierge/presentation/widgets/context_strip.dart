import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/concierge_providers.dart';
import '../../domain/trip_context_view.dart';

/// Horizontal scrollable pills showing live trip context
/// (location / weather / budget / pax / hotel) — UIUX AI-001.
class ContextStrip extends ConsumerWidget {
  const ContextStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripContextProvider);
    return SizedBox(
      height: 34,
      child: async.when(
        loading: () => const _LoadingPills(),
        error: (_, _) => const _Pill(icon: Icons.cloud_off, label: 'Offline'),
        data: (ctx) => _Pills(ctx: ctx),
      ),
    );
  }
}

class _Pills extends StatelessWidget {
  final TripContextView ctx;
  const _Pills({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _Pill(icon: Icons.place_outlined, label: ctx.area),
        _Pill(
          icon: Icons.wb_sunny_outlined,
          label: '${ctx.tempC}°C ${ctx.condition}',
        ),
        _Pill(
          icon: Icons.account_balance_wallet_outlined,
          label: '฿${ctx.budgetRemainingThb} left',
        ),
        _Pill(icon: Icons.groups_outlined, label: '${ctx.familySize} pax'),
        _Pill(icon: Icons.hotel_outlined, label: ctx.hotelName),
      ],
    );
  }
}

class _LoadingPills extends StatelessWidget {
  const _LoadingPills();
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: const [
        _Pill(icon: Icons.place_outlined, label: 'Loading trip…'),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
