import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/screen.dart';
import '../../../concierge/application/concierge_providers.dart';
import '../../../concierge/domain/concierge_models.dart';

/// AI Morning Briefing hero card — wired to GET /api/concierge/briefing.
class MorningBriefingCard extends ConsumerWidget {
  const MorningBriefingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(briefingProvider);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientOcean,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: kSoftShadow,
      ),
      child: async.when(
        loading: () => const SizedBox(
          height: 96,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
        ),
        error: (_, _) => const Text(
          'Could not load your briefing. Is the backend running on port 8000?',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        data: (b) => _BriefingContent(briefing: b),
      ),
    );
  }
}

class _BriefingContent extends StatelessWidget {
  final Briefing briefing;
  const _BriefingContent({required this.briefing});

  @override
  Widget build(BuildContext context) {
    final live = briefing.source == AnswerSource.ai;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientSunset),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'AI MORNING BRIEFING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFFF8A052),
              ),
            ),
            const Spacer(),
            Text(
              live ? 'live' : 'cached',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          briefing.headline,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${briefing.weatherLine}\n'
          '${briefing.firstActivity['time']} · ${briefing.firstActivity['name']} — '
          '${briefing.firstActivity['departure_tip']}',
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFFCBD9DE),
          ),
        ),
        if (briefing.aiTip.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '💡 ${briefing.aiTip}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD9DE)),
          ),
        ],
      ],
    );
  }
}
