import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;

  static bool get _isAvailable {
    try {
      _firestore ??= FirebaseFirestore.instance;
      _auth ??= FirebaseAuth.instance;
      return _auth!.currentUser != null;
    } catch (e) {
      debugPrint('Firestore not available: $e');
      return false;
    }
  }

  static String? get _userId => _auth?.currentUser?.uid;

  /// Get user's Firestore document reference
  static DocumentReference<Map<String, dynamic>>? getUserDoc() {
    if (!_isAvailable || _userId == null) return null;
    return _firestore!.collection('users').doc(_userId);
  }

  /// Get user's subcollection reference
  static CollectionReference<Map<String, dynamic>>? getUserCollection(String collectionName) {
    final userDoc = getUserDoc();
    if (userDoc == null) return null;
    return userDoc.collection(collectionName);
  }

  /// Save data to user's document field
  static Future<void> setUserField(String field, dynamic value) async {
    try {
      final doc = getUserDoc();
      if (doc == null) return;
      await doc.set({field: value}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting user field $field: $e');
    }
  }

  /// Get data from user's document field
  static Future<dynamic> getUserField(String field) async {
    try {
      final doc = getUserDoc();
      if (doc == null) return null;
      final snapshot = await doc.get();
      return snapshot.data()?[field];
    } catch (e) {
      debugPrint('Error getting user field $field: $e');
      return null;
    }
  }

  /// Add document to user's subcollection
  static Future<String?> addToCollection(String collectionName, Map<String, dynamic> data) async {
    try {
      final collection = getUserCollection(collectionName);
      if (collection == null) return null;
      final docRef = await collection.add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding to collection $collectionName: $e');
      return null;
    }
  }

  /// Set document in user's subcollection with specific ID
  static Future<void> setInCollection(String collectionName, String docId, Map<String, dynamic> data) async {
    try {
      final collection = getUserCollection(collectionName);
      if (collection == null) return;
      await collection.doc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting doc in collection $collectionName: $e');
    }
  }

  /// Get all documents from user's subcollection
  static Future<List<Map<String, dynamic>>> getCollection(String collectionName) async {
    try {
      final collection = getUserCollection(collectionName);
      if (collection == null) return [];
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('Error getting collection $collectionName: $e');
      return [];
    }
  }

  /// Delete document from user's subcollection
  static Future<void> deleteFromCollection(String collectionName, String docId) async {
    try {
      final collection = getUserCollection(collectionName);
      if (collection == null) return;
      await collection.doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting from collection $collectionName: $e');
    }
  }

  /// Clear entire subcollection
  static Future<void> clearCollection(String collectionName) async {
    try {
      final collection = getUserCollection(collectionName);
      if (collection == null) return;
      final snapshot = await collection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error clearing collection $collectionName: $e');
    }
  }
}
