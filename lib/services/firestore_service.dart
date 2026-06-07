import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference path helper
  CollectionReference<Map<String, dynamic>> _notesRef(String userId) {
    return _db.collection('users').doc(userId).collection('ramadhan_notes');
  }

  /// Save or update note for a specific date (yyyy-MM-dd)
  Future<void> saveNote(String userId, String dateStr, Map<String, dynamic> noteData) async {
    try {
      final data = {
        ...noteData,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _notesRef(userId).doc(dateStr).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error in FirestoreService.saveNote: $e");
      rethrow;
    }
  }

  /// Retrieve note for a specific date
  Future<DocumentSnapshot<Map<String, dynamic>>> getNote(String userId, String dateStr) async {
    try {
      return await _notesRef(userId).doc(dateStr).get();
    } catch (e) {
      debugPrint("Error in FirestoreService.getNote: $e");
      rethrow;
    }
  }

  /// Stream of notes for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> noteStream(String userId, String dateStr) {
    return _notesRef(userId).doc(dateStr).snapshots();
  }

  /// Delete note for a specific date
  Future<void> deleteNote(String userId, String dateStr) async {
    try {
      await _notesRef(userId).doc(dateStr).delete();
    } catch (e) {
      debugPrint("Error in FirestoreService.deleteNote: $e");
      rethrow;
    }
  }
}
