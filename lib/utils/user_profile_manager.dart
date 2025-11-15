import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class UserProfileManager {
  static const String _nameKey = 'user_name';
  static const String _avatarKey = 'user_avatar';
  static const String _categoryKey = 'favorite_category';

  /// Save user name
  static Future<void> setUserName(String name) async {
    try {
      await FirestoreService.setUserField('name', name);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, name);
    }
  }

  /// Get user name
  static Future<String?> getUserName() async {
    try {
      return await FirestoreService.getUserField('name') as String?;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nameKey);
    }
  }

  /// Save user avatar
  static Future<void> setUserAvatar(String avatarPath) async {
    try {
      await FirestoreService.setUserField('avatar', avatarPath);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, avatarPath);
    }
  }

  /// Get user avatar
  static Future<String?> getUserAvatar() async {
    try {
      return await FirestoreService.getUserField('avatar') as String?;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatarKey);
    }
  }

  /// Save favorite category
  static Future<void> setFavoriteCategory(String category) async {
    try {
      await FirestoreService.setUserField('favoriteCategory', category);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_categoryKey, category);
    }
  }

  /// Get favorite category
  static Future<String?> getFavoriteCategory() async {
    try {
      return await FirestoreService.getUserField('favoriteCategory') as String?;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_categoryKey);
    }
  }

  /// Clear all profile data
  static Future<void> clearProfile() async {
    try {
      final userDoc = FirestoreService.getUserDoc();
      if (userDoc != null) {
        await userDoc.delete();
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_avatarKey);
      await prefs.remove(_categoryKey);
    }
  }
}
