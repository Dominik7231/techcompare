// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
    );
  }

  Future<String> chat(String message) async {
    try {
      final prompt = '''
      You are a tech expert. You help with selecting iPhones and other tech devices.
      
      User question: $message
      
      Provide your answer in English, brief and clear!
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Sorry, I cannot answer.';
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
