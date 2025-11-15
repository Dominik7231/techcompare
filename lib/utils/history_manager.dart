import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';
import 'dart:convert';

class HistoryManager {
  static const String _searchKey = 'search_history';
  static const String _viewedKey = 'viewed_products';
  static const String _comparisonKey = 'comparison_history';
  static const int _maxItems = 50;

  /// Add search query to history
  static Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      await FirestoreService.addToCollection('searchHistory', {
        'query': query.trim(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchKey) ?? [];
      history.remove(query);
      history.insert(0, query);
      if (history.length > _maxItems) {
        history.removeRange(_maxItems, history.length);
      }
      await prefs.setStringList(_searchKey, history);
    }
  }

  /// Get search history
  static Future<List<String>> getSearchHistory() async {
    try {
      final docs = await FirestoreService.getCollection('searchHistory');
      docs.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      return docs.map((doc) => doc['query'] as String).take(_maxItems).toList();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_searchKey) ?? [];
    }
  }

  /// Clear search history
  static Future<void> clearSearchHistory() async {
    try {
      await FirestoreService.clearCollection('searchHistory');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchKey);
    }
  }

  /// Add viewed product
  static Future<void> addViewedProduct(String productId, String productName, String category) async {
    try {
      await FirestoreService.setInCollection('viewedProducts', productId, {
        'productId': productId,
        'productName': productName,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final viewed = prefs.getStringList(_viewedKey) ?? [];
      final item = json.encode({
        'id': productId,
        'name': productName,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      viewed.remove(item);
      viewed.insert(0, item);
      if (viewed.length > _maxItems) {
        viewed.removeRange(_maxItems, viewed.length);
      }
      await prefs.setStringList(_viewedKey, viewed);
    }
  }

  /// Get viewed products
  static Future<List<Map<String, dynamic>>> getViewedProducts() async {
    try {
      final docs = await FirestoreService.getCollection('viewedProducts');
      docs.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      return docs.take(_maxItems).toList();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final viewed = prefs.getStringList(_viewedKey) ?? [];
      return viewed.map((item) => json.decode(item) as Map<String, dynamic>).toList();
    }
  }

  /// Clear viewed products
  static Future<void> clearViewedProducts() async {
    try {
      await FirestoreService.clearCollection('viewedProducts');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_viewedKey);
    }
  }

  /// Add comparison to history
  static Future<void> addComparisonHistory(List<String> productIds, String category) async {
    try {
      await FirestoreService.addToCollection('comparisonHistory', {
        'productIds': productIds,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_comparisonKey) ?? [];
      final item = json.encode({
        'productIds': productIds,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      history.insert(0, item);
      if (history.length > _maxItems) {
        history.removeRange(_maxItems, history.length);
      }
      await prefs.setStringList(_comparisonKey, history);
    }
  }

  /// Get comparison history
  static Future<List<Map<String, dynamic>>> getComparisonHistory() async {
    try {
      final docs = await FirestoreService.getCollection('comparisonHistory');
      docs.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      return docs.take(_maxItems).toList();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_comparisonKey) ?? [];
      return history.map((item) => json.decode(item) as Map<String, dynamic>).toList();
    }
  }

  /// Clear comparison history
  static Future<void> clearComparisonHistory() async {
    try {
      await FirestoreService.clearCollection('comparisonHistory');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_comparisonKey);
    }
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    await clearSearchHistory();
    await clearViewedProducts();
    await clearComparisonHistory();
  }
}
