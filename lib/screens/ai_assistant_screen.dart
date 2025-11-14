import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../models/mac.dart';
import '../models/ipad.dart';
import '../services/ai_assistant.dart';
import '../utils/ai_usage_helper.dart';
import 'ai_chat_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  final List<Phone> phones;
  final List<Mac> macs;
  final List<iPad> ipads;

  const AIAssistantScreen({
    super.key,
    required this.phones,
    required this.macs,
    required this.ipads,
  });

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _recommendation;
  bool _isLoading = false;
  String _selectedCategory = 'Phones';
  int _remainingUses = 5;

  List<Phone> get _phones => widget.phones;
  List<Mac> get _macs => widget.macs;
  List<iPad> get _ipads => widget.ipads;

  String _promptTitle() {
    switch (_selectedCategory) {
      case 'Macs':
        return 'What are you looking for in a Mac?';
      case 'iPads':
        return 'What are you looking for in an iPad?';
      case 'All':
        return 'What are you looking for in a device?';
      default:
        return 'What are you looking for in a phone?';
    }
  }

  String _promptSubtitle() {
    switch (_selectedCategory) {
      case 'Macs':
        return 'For example: "Video editing", "Portable workstation", "External display support"';
      case 'iPads':
        return 'For example: "Drawing", "Note-taking", "Portable productivity"';
      case 'All':
        return 'For example: "Best for travel", "Gaming setup", "Great battery life"';
      default:
        return 'For example: "Good camera", "Gaming phone", "Long battery life"';
    }
  }

  Future<void> _getRecommendation() async {
    // Check AI usage and show ad if needed
    final canProceed = await AIUsageHelper.checkAndHandleAIUsage(context);
    if (!canProceed) {
      await _loadRemainingUses();
      return;
    }
    await _loadRemainingUses();

    if (_selectedCategory == 'Phones' && _phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phones available for recommendation.')),
      );
      return;
    }

    if (_selectedCategory == 'Macs' && _macs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Macs available for recommendation.')),
      );
      return;
    }

    if (_selectedCategory == 'iPads' && _ipads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No iPads available for recommendation.')),
      );
      return;
    }

    if (_selectedCategory == 'All' && _phones.isEmpty && _macs.isEmpty && _ipads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices available for recommendation.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendation = null;
    });

    final preference = _controller.text.trim().isEmpty ? null : _controller.text.trim();
    String recommendation;

    if (_selectedCategory == 'Phones') {
      recommendation = await AIAssistant.getPhoneRecommendation(
        phones: _phones,
        userPreference: preference,
      );
    } else if (_selectedCategory == 'Macs') {
      recommendation = await AIAssistant.getMacRecommendation(
        macs: _macs,
        userPreference: preference,
      );
    } else if (_selectedCategory == 'iPads') {
      recommendation = await AIAssistant.getiPadRecommendation(
        ipads: _ipads,
        userPreference: preference,
      );
    } else {
      // For 'All' category, we'll use phones for now (can be extended)
      recommendation = await AIAssistant.getPhoneRecommendation(
        phones: _phones,
        userPreference: preference,
      );
    }

    // Record AI usage after successful call
    await AIUsageHelper.recordAIUsage();
    await _loadRemainingUses();

    setState(() {
      _recommendation = recommendation;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRemainingUses();
  }

  Future<void> _loadRemainingUses() async {
    final remaining = await AIUsageHelper.getRemainingUses();
    if (mounted) {
      setState(() {
        _remainingUses = remaining;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Assistant (Coming soon!)'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: Center(
          child: Text(
            'Coming soon!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (value) {
        if (value) {
          setState(() {
            _selectedCategory = label;
            _recommendation = null;
          });
        }
      },
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      pressElevation: 0,
    );
  }
}
