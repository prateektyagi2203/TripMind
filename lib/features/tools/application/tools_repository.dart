import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class TranslationResult {
  final String translated;
  final String pronunciation;
  final String source; // ai | fallback
  const TranslationResult({
    required this.translated,
    required this.pronunciation,
    required this.source,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      TranslationResult(
        translated: json['translated'] as String? ?? '',
        pronunciation: json['pronunciation'] as String? ?? '',
        source: json['source'] as String? ?? 'fallback',
      );
}

class ToolsRepository {
  final Dio _dio;
  ToolsRepository(this._dio);

  Future<TranslationResult> translate(String text, String targetLang) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/tools/translate',
      data: {'text': text, 'target_lang': targetLang},
    );
    return TranslationResult.fromJson(res.data!);
  }
}

final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  return ToolsRepository(ref.watch(dioProvider));
});
