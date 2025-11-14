import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import 'ai_service_exception.dart';
import 'gemini_service.dart';
import 'openrouter_deepseek_service.dart';

class AIAssistant {
  static const String _legacyGeminiApiKey = 'AIzaSyAFltGac4ZxyjRsl9CX6H6RIV0EBvcMEI8';
  static final OpenRouterDeepSeekService _openRouterService = OpenRouterDeepSeekService();
  static final GeminiService _geminiService = GeminiService(_legacyGeminiApiKey);

  static Future<String> chatAboutPhones({
    required String userMessage,
    required List<Phone> phones,
    List<Map<String, String>>? conversationHistory,
  }) async {
    String phonesInfo = phones.map((phone) {
      String storageOptions = '${phone.storageOptions.join('GB, ')}GB';
      return '''
${phone.name}:
- Chip: ${phone.chip}
- Display: ${phone.display}
- Camera: ${phone.camera}
- Storage: $storageOptions
- Battery: ${phone.battery} mAh
- Price: ${phone.price} USD
- RAM: ${phone.ram ?? 'N/A'} GB
- Weight: ${phone.weight ?? 'N/A'} g
- 5G: ${phone.has5G ? 'Yes' : 'No'}
- Front Camera: ${phone.frontCamera ?? 'N/A'}''';
    }).join('\n');

    String conversationContext = '';
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      conversationContext = 'Previous conversation:\n';
      for (var msg in conversationHistory) {
        conversationContext += '${msg['role'] == 'user' ? 'User' : 'Assistant'}: ${msg['content']}\n';
      }
      conversationContext += '\n';
    }

    String fullMessage = '''$conversationContext
Available phones:
$phonesInfo

User question: $userMessage

Answer as a phone expert, friendly, informative and concise in English!''';

    return _requestAI(fullMessage);
  }

  static Future<String> chatAboutiPads({
    required String userMessage,
    required List<iPad> ipads,
    List<Map<String, String>>? conversationHistory,
  }) async {
    String ipadsInfo = ipads.map((ipad) {
      String ramOptions = '${ipad.ramOptions.join('GB, ')}GB';
      String storageOptions = '${ipad.storageOptions.join('GB, ')}GB';
      return '''
${ipad.name}:
- Chip: ${ipad.chip}
- Display: ${ipad.display}
- CPU: ${ipad.cpuDetails}
- GPU: ${ipad.gpuDetails}
- RAM Options: $ramOptions
- Storage Options: $storageOptions
- Battery: ${ipad.batteryHours ?? 'N/A'} hours
- Price: ${ipad.price} USD
- Form Factor: ${ipad.formFactor ?? 'N/A'}
- Ports: ${ipad.ports ?? 'N/A'}
${ipad.has5G != null ? '- 5G Support: ${ipad.has5G! ? 'Yes' : 'No'}' : ''}''';
    }).join('\n');

    String conversationContext = '';
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      conversationContext = 'Previous conversation:\n';
      for (var msg in conversationHistory) {
        conversationContext += '${msg['role'] == 'user' ? 'User' : 'Assistant'}: ${msg['content']}\n';
      }
      conversationContext += '\n';
    }

    String fullMessage = '''$conversationContext
Available iPads:
$ipadsInfo

User question: $userMessage

Answer as an iPad expert, friendly, informative and concise in English!''';

    return _requestAI(fullMessage);
  }

  static Future<String> chatAboutMacs({
    required String userMessage,
    required List<Mac> macs,
    List<Map<String, String>>? conversationHistory,
  }) async {
    String macsInfo = macs.map((mac) {
      String ramOptions = '${mac.ramOptions.join('GB, ')}GB';
      String storageOptions = '${mac.storageOptions.join('GB, ')}GB';
      return '''
${mac.name}:
- Chip: ${mac.chip}
- Display: ${mac.display}
- CPU: ${mac.cpuDetails}
- GPU: ${mac.gpuDetails}
- RAM Options: $ramOptions
- Storage Options: $storageOptions
- Battery: ${mac.batteryHours ?? 'N/A'} hours
- Price: ${mac.price} USD
- Form Factor: ${mac.formFactor ?? 'N/A'}
- Ports: ${mac.ports ?? 'N/A'}
- Refresh Rate: ${mac.refreshRate ?? 'N/A'} Hz''';
    }).join('\n');

    String conversationContext = '';
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      conversationContext = 'Previous conversation:\n';
      for (var msg in conversationHistory) {
        conversationContext += '${msg['role'] == 'user' ? 'User' : 'Assistant'}: ${msg['content']}\n';
      }
      conversationContext += '\n';
    }

    String fullMessage = '''$conversationContext
Available Macs:
$macsInfo

User question: $userMessage

Answer as a Mac expert, friendly, informative and concise in English!''';

    return _requestAI(fullMessage);
  }

  static Future<String> getPhoneRecommendation({
    required List<Phone> phones,
    String? userPreference,
  }) async {
    String phonesInfo = phones.map((phone) {
      String storageOptions = '${phone.storageOptions.join('GB, ')}GB';
      return '''
${phone.name}:
- Chip: ${phone.chip}
- Display: ${phone.display}
- Camera: ${phone.camera}
- Storage: $storageOptions
- Battery: ${phone.battery} mAh
- Price: ${phone.price} USD
- RAM: ${phone.ram ?? 'N/A'} GB
- Weight: ${phone.weight ?? 'N/A'} g
- 5G: ${phone.has5G ? 'Yes' : 'No'}
- Front Camera: ${phone.frontCamera ?? 'N/A'}''';
    }).join('\n');

    String message = '''You are a phone expert assistant. Help the user choose the best phone from the following options.

Phones:
$phonesInfo

${userPreference != null ? 'User preference: $userPreference\n' : ''}
Provide detailed recommendation in English, explain which phone is worth choosing and why. Consider value for money, performance and user needs. Answer in 3-4 paragraphs maximum.''';

    return _requestAI(message);
  }

  static Future<String> getMacRecommendation({
    required List<Mac> macs,
    String? userPreference,
  }) async {
    String macsInfo = macs.map((mac) {
      String ramOptions = '${mac.ramOptions.join('GB, ')}GB';
      String storageOptions = '${mac.storageOptions.join('GB, ')}GB';
      return '''
${mac.name}:
- Chip: ${mac.chip}
- Display: ${mac.display}
- CPU: ${mac.cpuDetails}
- GPU: ${mac.gpuDetails}
- RAM Options: $ramOptions
- Storage Options: $storageOptions
- Battery: ${mac.batteryHours ?? 'N/A'} hours
- Price: ${mac.price} USD
- Form Factor: ${mac.formFactor ?? 'N/A'}
- Ports: ${mac.ports ?? 'N/A'}
- Refresh Rate: ${mac.refreshRate ?? 'N/A'} Hz''';
    }).join('\n');

    String message = '''You are a Mac expert assistant. Help the user choose the best Mac from the following options.

Macs:
$macsInfo

${userPreference != null ? 'User preference: $userPreference\n' : ''}
Provide detailed recommendation in English, explain which Mac is worth choosing and why. Consider value for money, performance and user needs. Answer in 3-4 paragraphs maximum.''';

    return _requestAI(message);
  }

  static Future<String> getiPadRecommendation({
    required List<iPad> ipads,
    String? userPreference,
  }) async {
    String ipadsInfo = ipads.map((ipad) {
      String ramOptions = '${ipad.ramOptions.join('GB, ')}GB';
      String storageOptions = '${ipad.storageOptions.join('GB, ')}GB';
      return '''
${ipad.name}:
- Chip: ${ipad.chip}
- Display: ${ipad.display}
- CPU: ${ipad.cpuDetails}
- GPU: ${ipad.gpuDetails}
- RAM Options: $ramOptions
- Storage Options: $storageOptions
- Battery: ${ipad.batteryHours ?? 'N/A'} hours
- Price: ${ipad.price} USD
- Form Factor: ${ipad.formFactor ?? 'N/A'}
- Ports: ${ipad.ports ?? 'N/A'}
${ipad.has5G != null ? '- 5G Support: ${ipad.has5G! ? 'Yes' : 'No'}' : ''}''';
    }).join('\n');

    String message = '''You are an iPad expert assistant. Help the user choose the best iPad from the following options.

iPads:
$ipadsInfo

${userPreference != null ? 'User preference: $userPreference\n' : ''}
Provide detailed recommendation in English, explain which iPad is worth choosing and why. Consider value for money, performance and user needs. Answer in 3-4 paragraphs maximum.''';

    return _requestAI(message);
  }

  static Future<String> comparePhones(Phone phone1, Phone phone2) async {
    final message = '''Compare these two phones in detail:

1. ${phone1.name}:
- Chip: ${phone1.chip}
- Display: ${phone1.display}
- Camera: ${phone1.camera}
- Storage: ${phone1.storageOptions.join('GB, ')}GB
- Battery: ${phone1.battery} mAh
- Price: ${phone1.price} USD
- RAM: ${phone1.ram ?? 'N/A'} GB
- 5G: ${phone1.has5G ? 'Yes' : 'No'}

2. ${phone2.name}:
- Chip: ${phone2.chip}
- Display: ${phone2.display}
- Camera: ${phone2.camera}
- Storage: ${phone2.storageOptions.join('GB, ')}GB
- Battery: ${phone2.battery} mAh
- Price: ${phone2.price} USD
- RAM: ${phone2.ram ?? 'N/A'} GB
- 5G: ${phone2.has5G ? 'Yes' : 'No'}

Explain in English which is the better choice and why. Consider value for money as well.''';

    return _requestAI(message);
  }

  static Future<String> compareMacs(Mac mac1, Mac mac2) async {
    final message = '''Compare these two Macs in detail:

1. ${mac1.name}:
- Chip: ${mac1.chip}
- Display: ${mac1.display}
- CPU: ${mac1.cpuDetails}
- GPU: ${mac1.gpuDetails}
- RAM: ${mac1.ramOptions.join('GB, ')}GB
- Storage: ${mac1.storageOptions.join('GB, ')}GB
- Battery: ${mac1.batteryHours ?? 'N/A'} hours
- Price: ${mac1.price} USD
- Form Factor: ${mac1.formFactor ?? 'N/A'}

2. ${mac2.name}:
- Chip: ${mac2.chip}
- Display: ${mac2.display}
- CPU: ${mac2.cpuDetails}
- GPU: ${mac2.gpuDetails}
- RAM: ${mac2.ramOptions.join('GB, ')}GB
- Storage: ${mac2.storageOptions.join('GB, ')}GB
- Battery: ${mac2.batteryHours ?? 'N/A'} hours
- Price: ${mac2.price} USD
- Form Factor: ${mac2.formFactor ?? 'N/A'}

Explain in English which is the better choice and why. Consider value for money, performance needs, and use cases.''';

    return _requestAI(message);
  }

  static Future<String> compareiPads(iPad ipad1, iPad ipad2) async {
    String message = '''Compare these two iPads in detail:

1. ${ipad1.name}:
- Chip: ${ipad1.chip}
- Display: ${ipad1.display}
- CPU: ${ipad1.cpuDetails}
- GPU: ${ipad1.gpuDetails}
- RAM: ${ipad1.ramOptions.join('GB, ')}GB
- Storage: ${ipad1.storageOptions.join('GB, ')}GB
- Battery: ${ipad1.batteryHours ?? 'N/A'} hours
- Price: ${ipad1.price} USD
- Form Factor: ${ipad1.formFactor ?? 'N/A'}
${ipad1.has5G != null ? '- 5G Support: ${ipad1.has5G! ? 'Yes' : 'No'}' : ''}

2. ${ipad2.name}:
- Chip: ${ipad2.chip}
- Display: ${ipad2.display}
- CPU: ${ipad2.cpuDetails}
- GPU: ${ipad2.gpuDetails}
- RAM: ${ipad2.ramOptions.join('GB, ')}GB
- Storage: ${ipad2.storageOptions.join('GB, ')}GB
- Battery: ${ipad2.batteryHours ?? 'N/A'} hours
- Price: ${ipad2.price} USD
- Form Factor: ${ipad2.formFactor ?? 'N/A'}
${ipad2.has5G != null ? '- 5G Support: ${ipad2.has5G! ? 'Yes' : 'No'}' : ''}

Explain in English which is the better choice and why. Consider value for money, performance needs, and use cases.''';

    return _requestAI(message);
  }

  static Future<String> _requestAI(String message) async {
    try {
      return await _openRouterService.chat(message);
    } on AIServiceException catch (e) {
      if (e.isAuthError) {
        try {
          return await _geminiService.chat(message);
        } catch (geminiError) {
          return 'OpenRouter auth failed (${e.statusCode}). Gemini fallback also failed: $geminiError';
        }
      }
      return 'AI error: ${e.toString()}';
    } catch (e) {
      return 'AI error: ${e.toString()}';
    }
  }
}
