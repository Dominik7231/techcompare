import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';
import 'dart:convert';

class FilterPreset {
  final String id;
  final String name;
  final Map<String, dynamic> filters;
  final int timestamp;

  FilterPreset({
    required this.id,
    required this.name,
    required this.filters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filters': filters,
        'timestamp': timestamp,
      };

  factory FilterPreset.fromJson(Map<String, dynamic> json) => FilterPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        filters: Map<String, dynamic>.from(json['filters'] as Map),
        timestamp: json['timestamp'] as int,
      );
}

class FilterPresetManager {
  static const String _localKey = 'filter_presets';

  /// Save a filter preset
  static Future<void> savePreset(String name, Map<String, dynamic> filters) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final id = 'preset_$timestamp';
    
    try {
      await FirestoreService.setInCollection('filterPresets', id, {
        'id': id,
        'name': name,
        'filters': filters,
        'timestamp': timestamp,
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_localKey) ?? [];
      final preset = FilterPreset(
        id: id,
        name: name,
        filters: filters,
        timestamp: timestamp,
      );
      presetsJson.add(json.encode(preset.toJson()));
      await prefs.setStringList(_localKey, presetsJson);
    }
  }

  /// Get all filter presets
  static Future<List<FilterPreset>> getFilterPresets() async {
    try {
      final docs = await FirestoreService.getCollection('filterPresets');
      return docs.map((doc) => FilterPreset.fromJson(doc)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_localKey) ?? [];
      return presetsJson
          .map((jsonStr) => FilterPreset.fromJson(json.decode(jsonStr) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  /// Delete a preset
  static Future<void> deletePreset(String presetId) async {
    try {
      await FirestoreService.deleteFromCollection('filterPresets', presetId);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getStringList(_localKey) ?? [];
      presetsJson.removeWhere((jsonStr) {
        final preset = FilterPreset.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
        return preset.id == presetId;
      });
      await prefs.setStringList(_localKey, presetsJson);
    }
  }

  /// Clear all presets
  static Future<void> clearAllPresets() async {
    try {
      await FirestoreService.clearCollection('filterPresets');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey);
    }
  }
}
