import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/screen.dart';

/// Explore — browse offline destination packs. Mirrors Lovable `_app.explore.tsx`.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _packs = <_Pack>[
    _Pack(
      'Thailand',
      'TH',
      'Available now',
      '84 MB',
      true,
      AppColors.gradientSunset,
    ),
    _Pack('Japan', 'JP', 'Coming soon', '—', false, AppColors.gradientOcean),
    _Pack(
      'Singapore',
      'SG',
      'Coming soon',
      '—',
      false,
      AppColors.gradientSunset,
    ),
    _Pack('Dubai', 'AE', 'Coming soon', '—', false, AppColors.gradientOcean),
  ];

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: _Header(),
          ),
          Section(
            title: 'Offline destination packs',
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
              children: _packs.map((p) => _PackCard(pack: p)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Destination packs',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }
}

class _Pack {
  final String name;
  final String code;
  final String tag;
  final String size;
  final bool available;
  final List<Color> gradient;
  const _Pack(
    this.name,
    this.code,
    this.tag,
    this.size,
    this.available,
    this.gradient,
  );
}

class _PackCard extends StatelessWidget {
  final _Pack pack;
  const _PackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: kSoftShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pack.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pack.tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 13,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pack.size,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: pack.available ? () {} : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ocean,
                      disabledBackgroundColor: AppColors.muted,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          size: 15,
                          color: pack.available
                              ? Colors.white
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 12,
                            color: pack.available
                                ? Colors.white
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
