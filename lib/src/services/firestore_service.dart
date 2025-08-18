import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/warning_model.dart';

class FirestoreService {
  FirestoreService._private();
  static final FirestoreService instance = FirestoreService._private();

  final CollectionReference<Map<String, dynamic>> _warnings =
      FirebaseFirestore.instance.collection('warnings');

  Stream<List<WarningModel>> streamWarnings({bool onlyActive = true}) {
    Query<Map<String, dynamic>> query = _warnings.orderBy('timestamp', descending: true);
    if (onlyActive) {
      query = query.where('active', isEqualTo: true);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => WarningModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> createWarning(WarningModel w) async {
    await _warnings.add(w.toMap());
  }

  Future<void> updateWarning(WarningModel w) async {
    await _warnings.doc(w.id).update(w.toMap());
  }

  Future<void> deleteWarning(String id) async {
    await _warnings.doc(id).delete();
  }

  // Admin can write a notifications document that Cloud Function will pick up
  Future<void> sendNotificationPayload(Map<String, dynamic> payload) async {
    await FirebaseFirestore.instance.collection('notifications').add(payload);
  }
}
