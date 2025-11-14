import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppSettings {
  static String currency = 'USD'; // USD, EUR, HUF
  static Set<String> favorites = {};
  
  static final Map<String, double> exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'HUF': 360.0,
  };
  
  static final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'HUF': 'Ft',
  };
  
  static String formatPrice(double priceInUSD) {
    final rate = exchangeRates[currency] ?? 1.0;
    final convertedPrice = (priceInUSD * rate).round();
    final symbol = currencySymbols[currency] ?? '\$';
    
    if (currency == 'HUF') {
      return '$convertedPrice $symbol';
    }
    return '$symbol$convertedPrice';
  }
  
  static void toggleFavorite(String phoneName) {
    if (favorites.contains(phoneName)) {
      favorites.remove(phoneName);
    } else {
      favorites.add(phoneName);
    }
  }
  
  static bool isFavorite(String phoneName) {
    return favorites.contains(phoneName);
  }
}

class AIUsageManager {
  static const String _keyAIUsageCount = 'ai_usage_count';
  static const String _keyMaxFreeUsage = 'max_free_usage';
  static const String _keyRewardUsage = 'reward_usage';
  static const String _keyPromoUsed = 'ai_promo_used_0505';
  
  // Default values (can be changed dynamically)
  static const int _defaultMaxFreeUsage = 5;
  static const int _defaultRewardUsage = 5;

  // Get max free usage (dynamic, stored in SharedPreferences)
  static Future<int> getMaxFreeUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxFreeUsage) ?? _defaultMaxFreeUsage;
  }

  // Set max free usage (dynamic)
  static Future<void> setMaxFreeUsage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxFreeUsage, value);
  }

  // Get reward usage (dynamic, stored in SharedPreferences)
  static Future<int> getRewardUsage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRewardUsage) ?? _defaultRewardUsage;
  }

  // Set reward usage (dynamic)
  static Future<void> setRewardUsage(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRewardUsage, value);
  }

  // Get current AI usage count
  static Future<int> getUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAIUsageCount) ?? 0;
  }

  // Increment AI usage count
  static Future<int> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyAIUsageCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyAIUsageCount, newCount);
    return newCount;
  }

  // Check if user needs to watch ad (reached max free usage)
  static Future<bool> needsToWatchAd() async {
    final count = await getUsageCount();
    final maxFreeUsage = await getMaxFreeUsage();
    // Show ad when count reaches maxFreeUsage, 2*maxFreeUsage, etc. (before using, so count is already at threshold)
    return count > 0 && (count % maxFreeUsage == 0);
  }

  // Add reward usage after watching ad
  static Future<void> addRewardUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyAIUsageCount) ?? 0;
    final maxFreeUsage = await getMaxFreeUsage();
    final rewardUsage = await getRewardUsage();
    // Subtract the max free usage and add reward, so user gets rewardUsage more uses
    await prefs.setInt(_keyAIUsageCount, currentCount - maxFreeUsage + rewardUsage);
  }

  // Get remaining free uses
  static Future<int> getRemainingUses() async {
    final count = await getUsageCount();
    final maxFreeUsage = await getMaxFreeUsage();
    if (count < maxFreeUsage) {
      return maxFreeUsage - count;
    }
    // After watching ads, calculate remaining uses
    final remainder = count % maxFreeUsage;
    return remainder == 0 ? 0 : maxFreeUsage - remainder;
  }

  // Check if user can use AI (has remaining uses)
  static Future<bool> canUseAI() async {
    final count = await getUsageCount();
    final maxFreeUsage = await getMaxFreeUsage();
    return count < maxFreeUsage || (count % maxFreeUsage != 0);
  }

  // Reset usage count (used when ad fails to load)
  static Future<void> resetUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_keyAIUsageCount) ?? 0;
    final maxFreeUsage = await getMaxFreeUsage();
    // Reset to previous multiple of maxFreeUsage, so user can continue
    final resetCount = (currentCount ~/ maxFreeUsage) * maxFreeUsage;
    await prefs.setInt(_keyAIUsageCount, resetCount);
  }

  // Apply promo code 0505: add +100 AI requests once
  static Future<bool> applyPromo0505() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyUsed = prefs.getBool(_keyPromoUsed) ?? false;
    if (alreadyUsed) {
      return false;
    }

    final currentCount = prefs.getInt(_keyAIUsageCount) ?? 0;
    await prefs.setInt(_keyAIUsageCount, currentCount.clamp(0, currentCount) - 100);
    await prefs.setBool(_keyPromoUsed, true);
    return true;
  }
}

class SecretSettings {
  static const String _keyOpenRouterApiKey = 'openrouter_api_key';

  static Future<String?> getOpenRouterApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOpenRouterApiKey);
  }

  static Future<void> setOpenRouterApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOpenRouterApiKey, value);
  }
}

// User Profile Manager
class UserProfileManager {
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyFavoriteCategory = 'favorite_category';
  
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }
  
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }
  
  static Future<String> getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAvatar) ?? '👤';
  }
  
  static Future<void> setUserAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatar, avatar);
  }
  
  static Future<String?> getFavoriteCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFavoriteCategory);
  }
  
  static Future<void> setFavoriteCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavoriteCategory, category);
  }
}

// History Manager
class HistoryManager {
  static const String _keySearchHistory = 'search_history';
  static const String _keyViewedProducts = 'viewed_products';
  static const String _keyComparisonHistory = 'comparison_history';
  static const int _maxHistoryItems = 50;
  
  // Search History
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySearchHistory);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final history = await getSearchHistory();
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to beginning
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearchHistory, jsonEncode(history));
  }
  
  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySearchHistory);
  }
  
  // Viewed Products
  static Future<List<Map<String, dynamic>>> getViewedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyViewedProducts);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> addViewedProduct(String name, String category, String type) async {
    final viewed = await getViewedProducts();
    // Remove if exists
    viewed.removeWhere((item) => item['name'] == name && item['category'] == category);
    // Add to beginning
    viewed.insert(0, {
      'name': name,
      'category': category,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (viewed.length > _maxHistoryItems) {
      viewed.removeRange(_maxHistoryItems, viewed.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyViewedProducts, jsonEncode(viewed));
  }
  
  static Future<void> clearViewedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyViewedProducts);
  }
  
  // Comparison History
  static Future<List<Map<String, dynamic>>> getComparisonHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyComparisonHistory);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> addComparisonHistory(List<String> productNames, String category) async {
    final history = await getComparisonHistory();
    history.insert(0, {
      'products': productNames,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyComparisonHistory, jsonEncode(history));
  }
  
  static Future<void> clearComparisonHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyComparisonHistory);
  }
}

// Filter Preset Manager
class FilterPresetManager {
  static const String _keyFilterPresets = 'filter_presets';
  static const String _keyDefaultPreset = 'default_preset';
  
  static Future<List<Map<String, dynamic>>> getFilterPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyFilterPresets);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> saveFilterPreset(String name, Map<String, dynamic> filters) async {
    final presets = await getFilterPresets();
    // Remove if exists
    presets.removeWhere((preset) => preset['name'] == name);
    // Add/update
    presets.add({
      'name': name,
      'filters': filters,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFilterPresets, jsonEncode(presets));
  }
  
  static Future<void> deleteFilterPreset(String name) async {
    final presets = await getFilterPresets();
    presets.removeWhere((preset) => preset['name'] == name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFilterPresets, jsonEncode(presets));
    
    // If deleted preset was default, clear default
    final defaultPreset = await getDefaultPreset();
    if (defaultPreset == name) {
      await setDefaultPreset(null);
    }
  }
  
  static Future<String?> getDefaultPreset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultPreset);
  }
  
  static Future<void> setDefaultPreset(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null) {
      await prefs.remove(_keyDefaultPreset);
    } else {
      await prefs.setString(_keyDefaultPreset, name);
    }
  }
  
  static Future<Map<String, dynamic>?> loadFilterPreset(String name) async {
    final presets = await getFilterPresets();
    try {
      final preset = presets.firstWhere((p) => p['name'] == name);
      return preset['filters'] as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}

// Recommendation Manager
class RecommendationManager {
  static Future<List<String>> getRecommendedProductNames(String category) async {
    // Get recommendations based on:
    // 1. Viewed products
    // 2. Search history
    // 3. Favorite category
    final viewed = await HistoryManager.getViewedProducts();
    // Note: searches and favoriteCategory can be used for future enhancements
    // final searches = await HistoryManager.getSearchHistory();
    // final favoriteCategory = await UserProfileManager.getFavoriteCategory();
    
    // Filter by category
    final categoryViewed = viewed.where((item) => item['category'] == category).toList();
    
    // Get most viewed products
    final Map<String, int> productCounts = {};
    for (var item in categoryViewed) {
      final name = item['name'] as String;
      productCounts[name] = (productCounts[name] ?? 0) + 1;
    }
    
    // Sort by count and return top 5
    final sorted = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => e.key).toList();
  }
}
