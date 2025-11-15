import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class FavoritesManager {
  static const String _localKey = 'favorite_phones';

  /// Add phone to favorites (Firestore + local fallback)
  static Future<void> addFavorite(String phoneId) async {
    try {
      // Try Firestore first
      await FirestoreService.setInCollection('favorites', phoneId, {
        'phoneId': phoneId,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_localKey) ?? [];
      if (!favorites.contains(phoneId)) {
        favorites.add(phoneId);
        await prefs.setStringList(_localKey, favorites);
      }
    }
  }

  /// Remove phone from favorites
  static Future<void> removeFavorite(String phoneId) async {
    try {
      // Try Firestore first
      await FirestoreService.deleteFromCollection('favorites', phoneId);
    } catch (e) {
      // Fallback to local
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_localKey) ?? [];
      favorites.remove(phoneId);
      await prefs.setStringList(_localKey, favorites);
    }
  }

  /// Check if phone is in favorites
  static Future<bool> isFavorite(String phoneId) async {
    try {
      // Try Firestore first
      final docs = await FirestoreService.getCollection('favorites');
      return docs.any((doc) => doc['phoneId'] == phoneId);
    } catch (e) {
      // Fallback to local
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_localKey) ?? [];
      return favorites.contains(phoneId);
    }
  }

  /// Get all favorite phone IDs
  static Future<List<String>> getFavorites() async {
    try {
      // Try Firestore first
      final docs = await FirestoreService.getCollection('favorites');
      return docs.map((doc) => doc['phoneId'] as String).toList();
    } catch (e) {
      // Fallback to local
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_localKey) ?? [];
    }
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    try {
      await FirestoreService.clearCollection('favorites');
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey);
    }
  }
}
