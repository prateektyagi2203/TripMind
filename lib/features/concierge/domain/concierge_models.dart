// Domain models for the AI Concierge feature. Plain immutable Dart classes
// mapping the FastAPI JSON contract (see backend/app/models.py).

/// A structured payload rendered as a card inside the chat stream.
class RichCard {
  final String type; // cab_comparison | budget_summary | weather_detail | ...
  final Map<String, dynamic> data;

  const RichCard({required this.type, required this.data});

  factory RichCard.fromJson(Map<String, dynamic> json) => RichCard(
    type: json['type'] as String,
    data: Map<String, dynamic>.from(json['data'] as Map),
  );
}

/// Where an answer came from. `deterministic` means the intent router answered
/// from TripContext without spending an LLM call.
enum AnswerSource { deterministic, ai, fallback }

AnswerSource _sourceFromString(String? s) {
  switch (s) {
    case 'deterministic':
      return AnswerSource.deterministic;
    case 'ai':
      return AnswerSource.ai;
    default:
      return AnswerSource.fallback;
  }
}

class ChatResponse {
  final String text;
  final AnswerSource source;
  final RichCard? richCard;

  const ChatResponse({required this.text, required this.source, this.richCard});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    text: json['text'] as String,
    source: _sourceFromString(json['source'] as String?),
    richCard: json['rich_card'] == null
        ? null
        : RichCard.fromJson(
            Map<String, dynamic>.from(json['rich_card'] as Map),
          ),
  );
}

/// Who authored a chat bubble.
enum ChatRole { user, assistant }

/// A single message in the conversation UI.
class ChatMessage {
  final ChatRole role;
  final String content;
  final RichCard? card;
  final AnswerSource? source;
  final bool pending;

  const ChatMessage({
    required this.role,
    required this.content,
    this.card,
    this.source,
    this.pending = false,
  });

  Map<String, String> toApiJson() => {
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'content': content,
  };
}

/// Morning briefing card (GET /api/concierge/briefing).
class Briefing {
  final String headline;
  final String weatherLine;
  final Map<String, String> firstActivity;
  final String budgetLine;
  final String aiTip;
  final List<String> alerts;
  final AnswerSource source;

  const Briefing({
    required this.headline,
    required this.weatherLine,
    required this.firstActivity,
    required this.budgetLine,
    required this.aiTip,
    required this.alerts,
    required this.source,
  });

  factory Briefing.fromJson(Map<String, dynamic> json) => Briefing(
    headline: json['headline'] as String,
    weatherLine: json['weather_line'] as String,
    firstActivity: (json['first_activity'] as Map).map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    ),
    budgetLine: json['budget_line'] as String,
    aiTip: json['ai_tip'] as String,
    alerts: (json['alerts'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    source: _sourceFromString(json['source'] as String?),
  );
}
