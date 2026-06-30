import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';

/// Receipts — empty receipt scanner. Mirrors `_app.tools.receipts.tsx`.
class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Receipts', leading: BackLeading()),
          Expanded(
            child: EmptyState(
              icon: Icons.photo_camera_rounded,
              title: 'No receipts yet',
              subtitle:
                  'Snap a photo to auto-log expenses and split with family.',
              action: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sunset,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Scan receipt'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
