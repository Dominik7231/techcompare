import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqAIService {
  final String apiKey;
  static const String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  GroqAIService(this.apiKey);

  Future<String> comparePhones(List<String> phoneNames) async {
    final prompt = '''
Compare these phones briefly in English:
${phoneNames.join(', ')}

Provide:
- Who is it recommended for
- Main advantages
- Use cases
''';
    
    return await chat(prompt);
  }

  Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant', // Fast and free!
          'messages': [
            {
              'role': 'system',
              'content': 'You are a tech expert. Answer briefly and clearly in English. You help with selecting phones and other tech devices.',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 800,
          'top_p': 1,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 401) {
        return 'API key error: Invalid or expired API key. Please check!';
      } else if (response.statusCode == 429) {
        return 'Too many requests, wait a bit and try again!';
      } else {
        // Detailed error message
        String errorMsg = 'Error occurred (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMsg += ': ${errorData['error']['message'] ?? errorData['error']}';
          } else {
            errorMsg += ': ${response.body}';
          }
        } catch (e) {
          errorMsg += ': ${response.body}';
        }
        return errorMsg;
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // Specific questions about phones
  Future<String> askAboutPhone(String question) async {
    final prompt = '''
Question about iPhones or phones: $question

Give a short, helpful answer in English!
''';
    return await chat(prompt);
  }

  // Buying advice
  Future<String> getBuyingAdvice({
    required String budget,
    required String usage,
  }) async {
    final prompt = '''
Help with iPhone selection:
- Budget: $budget
- Usage: $usage

Which iPhone do you recommend and why? Briefly!
''';
    return await chat(prompt);
  }
}
