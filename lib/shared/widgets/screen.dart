import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Mirror of Lovable's `Screen` + `ScreenHeader` + `Section` primitives
/// (reference/lovable-source/src/components/screen.tsx).

/// A full-height screen body on the warm paper background.
class Screen extends StatelessWidget {
  final Widget child;
  const Screen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(bottom: false, child: child),
    );
  }
}

/// Sticky glassy header with a centered display title + optional subtitle.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xCCFEFAF1), // surface-glass (80% paper)
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: leading),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}

/// A titled content section with a display heading.
class Section extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const Section({
    super.key,
    required this.title,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Soft shadow used across Lovable cards (`shadow-soft`).
const List<BoxShadow> kSoftShadow = [
  BoxShadow(
    color: Color(0x14031E29),
    blurRadius: 32,
    offset: Offset(0, 12),
    spreadRadius: -12,
  ),
];
