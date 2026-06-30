import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../application/tools_repository.dart';

/// Translator — text translation wired to the GPT-4o backend
/// (`POST /api/tools/translate`). Mirrors `_app.tools.translator.tsx`, enriched
/// with a working text mode.
class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({super.key});

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final _controller = TextEditingController();
  TranslationResult? _result;
  bool _loading = false;
  String _targetLang = 'Thai';

  static const _recent = [
    'Where is the nearest pharmacy?',
    'Two waters, no ice please.',
    'How much does this cost?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _translate([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    if (preset != null) _controller.text = preset;
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(toolsRepositoryProvider)
          .translate(text, _targetLang);
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _result = const TranslationResult(
          translated: "Couldn't reach the translator. Is the backend running?",
          pronunciation: '',
          source: 'fallback',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Column(
        children: [
          const ScreenHeader(title: 'Translator', leading: BackLeading()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    const _LangPill(label: 'English'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    _LangPill(
                      label: _targetLang,
                      onTap: () => setState(
                        () => _targetLang = _targetLang == 'Thai'
                            ? 'Japanese'
                            : 'Thai',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PlainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type something to translate…',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _translate(),
                      ),
                      const Divider(color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: _loading ? null : () => _translate(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.ocean,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Translate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _ResultCard(result: _result!),
                ],
                const SizedBox(height: 24),
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ..._recent.map(
                  (phrase) => GestureDetector(
                    onTap: () => _translate(phrase),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              phrase,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_east_rounded,
                            size: 16,
                            color: AppColors.ocean,
                          ),
                        ],
                      ),
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

class _LangPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _LangPill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final TranslationResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isAi = result.source == 'ai';
    return GradientHeroCard(
      colors: AppColors.gradientOcean,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Translation',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAi ? 'GPT-4o' : 'offline',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.translated,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (result.pronunciation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              result.pronunciation,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}
