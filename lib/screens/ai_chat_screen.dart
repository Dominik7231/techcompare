import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import '../services/ai_assistant.dart';
import '../utils/ai_usage_helper.dart';
import '../secrets.dart' if (dart.library.html) '../secrets_stub.dart';

class AIChatScreen extends StatefulWidget {
  final List<Phone> phones;
  final List<Mac> macs;
  final List<iPad> ipads;

  const AIChatScreen({
    Key? key,
    this.phones = const [],
    this.macs = const [],
    this.ipads = const [],
  }) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  int _remainingUses = 5;

  @override
  void initState() {
    super.initState();
    _loadRemainingUses();
    _messages.add({
      'role': 'assistant',
      'content': 'Coming soon!',
    });
  }

  Future<void> _loadRemainingUses() async {
    final remaining = await AIUsageHelper.getRemainingUses();
    if (mounted) {
      setState(() {
        _remainingUses = remaining;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final key = openRouterApiKey.trim();
    if (key.isEmpty || key == 'YOUR_OPENROUTER_API_KEY_HERE') {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'AI is not configured. Please add your OpenRouter API key in secrets.dart to enable AI features.',
        });
      });
      return;
    }

    // Check AI usage and show ad if needed
    final canProceed = await AIUsageHelper.checkAndHandleAIUsage(context);
    if (!canProceed) {
      await _loadRemainingUses();
      return;
    }
    await _loadRemainingUses();

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
      });
      _isLoading = true;
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    // Get AI response
    String response;
    if (widget.phones.isNotEmpty) {
      response = await AIAssistant.chatAboutPhones(
        userMessage: userMessage,
        phones: widget.phones,
        conversationHistory: _messages.where((m) => m['role'] != 'assistant' || _messages.indexOf(m) > 0).toList(),
      );
    } else if (widget.macs.isNotEmpty) {
      response = await AIAssistant.chatAboutMacs(
        userMessage: userMessage,
        macs: widget.macs,
        conversationHistory: _messages.where((m) => m['role'] != 'assistant' || _messages.indexOf(m) > 0).toList(),
      );
    } else if (widget.ipads.isNotEmpty) {
      response = await AIAssistant.chatAboutiPads(
        userMessage: userMessage,
        ipads: widget.ipads,
        conversationHistory: _messages.where((m) => m['role'] != 'assistant' || _messages.indexOf(m) > 0).toList(),
      );
    } else {
      response = 'Please select some products to compare first.';
    }

    if (!(response.startsWith('AI is not configured') || response.startsWith('AI error:') || response.startsWith('Error occurred:') || response.contains('took too long'))) {
      await AIUsageHelper.recordAIUsage();
    }
    await _loadRemainingUses();

    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': response,
      });
      _isLoading = false;
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Chat with AI (Coming soon!)'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingUses > 0 ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${_remainingUses} uses left',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                String welcomeMessage;
                if (widget.phones.isNotEmpty) {
                  welcomeMessage = 'Hi! I\'m your phone expert assistant. Ask me anything about these ${widget.phones.length} phones, and I\'ll help you find the perfect match! 📱';
                } else if (widget.macs.isNotEmpty) {
                  welcomeMessage = 'Hi! I\'m your Mac expert assistant. Ask me anything about these ${widget.macs.length} Macs, and I\'ll help you find the perfect match! 💻';
                } else if (widget.ipads.isNotEmpty) {
                  welcomeMessage = 'Hi! I\'m your iPad expert assistant. Ask me anything about these ${widget.ipads.length} iPads, and I\'ll help you find the perfect match! 📱';
                } else {
                  welcomeMessage = 'Hi! I\'m your tech expert assistant. How can I help you today?';
                }
                _messages.add({
                  'role': 'assistant',
                  'content': welcomeMessage,
                });
              });
            },
            tooltip: 'Reset chat',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser 
                                  ? Colors.deepPurple.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message['content'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Loading indicator
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Coming soon!',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: null,
                      backgroundColor: Colors.deepPurple,
                      child: const Icon(Icons.send),
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
