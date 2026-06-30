import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/concierge_models.dart';
import '../domain/trip_context_view.dart';

/// Talks to the FastAPI Concierge backend.
class ConciergeRepository {
  final Dio _dio;
  ConciergeRepository(this._dio);

  Future<ChatResponse> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/concierge/chat',
      data: {
        'message': message,
        'history': history.map((m) => m.toApiJson()).toList(),
      },
    );
    return ChatResponse.fromJson(res.data!);
  }

  Future<Briefing> fetchBriefing() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/concierge/briefing');
    return Briefing.fromJson(res.data!);
  }

  Future<TripContextView> fetchTripContext() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/trip-context');
    return TripContextView.fromJson(res.data!);
  }
}

final conciergeRepositoryProvider = Provider<ConciergeRepository>((ref) {
  return ConciergeRepository(ref.watch(dioProvider));
});
