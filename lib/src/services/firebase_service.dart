import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Simple wrapper for static initialization and references
class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    // Any global Firebase initialization can be added here.
    // Firestore settings or analytics toggles can be configured.
    FirebaseFirestore.instance.settings = const Settings();
  }
}
