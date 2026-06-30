import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/concierge_models.dart';
import '../domain/trip_context_view.dart';
import '../infrastructure/concierge_repository.dart';

/// Trip context for the header pills (loaded once).
final tripContextProvider = FutureProvider<TripContextView>((ref) {
  return ref.watch(conciergeRepositoryProvider).fetchTripContext();
});

/// Morning briefing card on the Trips home screen.
final briefingProvider = FutureProvider<Briefing>((ref) {
  return ref.watch(conciergeRepositoryProvider).fetchBriefing();
});

/// Holds the live conversation and drives sending messages.
class ConciergeChatNotifier extends StateNotifier<List<ChatMessage>> {
  ConciergeChatNotifier(this._repo) : super(const [_greeting]);

  final ConciergeRepository _repo;

  static const _greeting = ChatMessage(
    role: ChatRole.assistant,
    content:
        "Hi! I have your Thailand trip context loaded. I can plan your days, "
        "compare taxis, translate, or surface hidden gems. What would you like to do?",
    source: AnswerSource.deterministic,
  );

  bool _sending = false;
  bool get isSending => _sending;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    final history = List<ChatMessage>.from(state);
    state = [
      ...state,
      ChatMessage(role: ChatRole.user, content: trimmed),
      const ChatMessage(role: ChatRole.assistant, content: '', pending: true),
    ];
    _sending = true;

    try {
      final reply = await _repo.sendMessage(trimmed, history);
      _replacePending(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply.text,
          card: reply.richCard,
          source: reply.source,
        ),
      );
    } catch (e) {
      _replacePending(
        const ChatMessage(
          role: ChatRole.assistant,
          content:
              "I couldn't reach the concierge service. Make sure the backend is "
              "running on port 8000, then try again.",
          source: AnswerSource.fallback,
        ),
      );
    } finally {
      _sending = false;
    }
  }

  void _replacePending(ChatMessage message) {
    final next = List<ChatMessage>.from(state);
    final idx = next.lastIndexWhere((m) => m.pending);
    if (idx >= 0) {
      next[idx] = message;
    } else {
      next.add(message);
    }
    state = next;
  }
}

final conciergeChatProvider =
    StateNotifierProvider<ConciergeChatNotifier, List<ChatMessage>>((ref) {
      return ConciergeChatNotifier(ref.watch(conciergeRepositoryProvider));
    });
