import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// In local/dev builds, you should have lib/secrets.dart with your real key.
// In web/CI builds (where secrets.dart is not present), we fall back to secrets_stub.dart.
import '../secrets.dart' if (dart.library.html) '../secrets_stub.dart';
import '../utils/settings.dart';
import 'ai_service_exception.dart';

class OpenRouterDeepSeekService {
  static const String _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'deepseek/deepseek-r1-t2-chimera:free';

  Future<String> chat(String message) async {
    try {
      final effectiveKey = await _resolveApiKey();
      if (effectiveKey.isEmpty || effectiveKey == 'YOUR_OPENROUTER_API_KEY_HERE') {
        throw const AIServiceException(
          source: 'OpenRouter',
          message: 'API key missing. Please add your OpenRouter key in secrets.dart or in SecretSettings.',
          statusCode: 401,
          isAuthError: true,
        );
      }
      final uri = Uri.parse(_endpoint);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + effectiveKey,
      };

      final body = jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful tech expert assistant for phone, Mac and iPad comparisons. Answer in clear, friendly English.'
          },
          {
            'role': 'user',
            'content': message,
          },
        ],
      });

      final response = await http.post(uri, headers: headers, body: body).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode != 200) {
        throw AIServiceException(
          source: 'OpenRouter',
          message: response.body,
          statusCode: response.statusCode,
          isAuthError: response.statusCode == 401 || response.statusCode == 403,
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const AIServiceException(
          source: 'OpenRouter',
          message: 'Empty response from OpenRouter',
        );
      }

      final messageObj = choices.first['message'] as Map<String, dynamic>?;
      final content = messageObj != null ? messageObj['content'] as String? : null;

      if (content == null || content.trim().isEmpty) {
        throw const AIServiceException(
          source: 'OpenRouter',
          message: 'Missing content in response',
        );
      }

      return content.trim();
    } on TimeoutException {
      throw const AIServiceException(
        source: 'OpenRouter',
        message: 'Request timed out. Please try again.',
      );
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException(
        source: 'OpenRouter',
        message: e.toString(),
      );
    }
  }

  Future<String> _resolveApiKey() async {
    final runtimeKey = await SecretSettings.getOpenRouterApiKey();
    if (runtimeKey != null && runtimeKey.trim().isNotEmpty) {
      return runtimeKey.trim();
    }
    return openRouterApiKey.trim();
  }
}
