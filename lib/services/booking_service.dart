import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final _db = FirebaseFirestore.instance;

  Future<void> bookEvent(String userId, String eventId) async {
    final id = const Uuid().v4();

    await _db.collection('bookings').doc(id).set({
      'userId': userId,
      'eventId': eventId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}