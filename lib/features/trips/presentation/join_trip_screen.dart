import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../../trip_create/presentation/create_trip_screen.dart';
import '../application/trips_repository.dart';
import '../domain/trip.dart';

/// Join an existing trip by entering the 6-character invite code the creator
/// shared. After joining, the trip appears in the user's trip list.
class JoinTripScreen extends ConsumerStatefulWidget {
  const JoinTripScreen({super.key});

  static Future<Trip?> show(BuildContext context) {
    return Navigator.of(
      context,
    ).push<Trip>(MaterialPageRoute(builder: (_) => const JoinTripScreen()));
  }

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final _codeCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _error = 'Enter the full invite code');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final trip = await ref.read(tripsRepositoryProvider).join(code);
      ref.invalidate(tripsListProvider);
      if (!mounted) return;
      Navigator.of(context).pop(trip);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'No trip found for that code.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Screen(
        child: Column(
          children: [
            const ScreenHeader(title: 'Join a trip', leading: BackLeading()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.group_add_rounded,
                      size: 48,
                      color: AppColors.ocean,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter invite code',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ask the trip creator for their 6-character code. You\'ll see the same itinerary, hotels and flights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _codeCtrl,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [UpperCaseTextFormatter()],
                      style: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ABC123',
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _join(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _join,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Join trip'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
