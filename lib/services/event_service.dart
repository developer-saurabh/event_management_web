import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

class EventService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImage(html.File file) async {
    print("📂 uploadImage() called");

    final id = const Uuid().v4();
    final ref = _storage.ref().child("event_images/$id.jpg");

    print("📡 Uploading to Firebase Storage...");

    await ref.putBlob(file);

    final url = await ref.getDownloadURL();

    print("🌍 Download URL generated: $url");

    return url;
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String date,
    required double price,
    required int ticketLimit,
    required String imageUrl,
    required String organizerId,
  }) async {
    final id = const Uuid().v4();

    await _db.collection('events').doc(id).set({
      'title': title,
      'description': description,
      'date': date,
      'price': price,
      'ticketLimit': ticketLimit,
      'ticketsSold': 0,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
    });

     print("✅ Firestore event created with ID: $id");
  }

  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').snapshots();
  }

  Stream<QuerySnapshot> getBookings(String eventId) {
    return _db
        .collection('bookings')
        .where('eventId', isEqualTo: eventId)
        .snapshots();
  }

  Future<void> deleteEvent(String eventId) async {
    // 1️⃣ Delete all bookings of this event
    final bookings =
        await _db
            .collection('bookings')
            .where('eventId', isEqualTo: eventId)
            .get();

    for (var doc in bookings.docs) {
      await doc.reference.delete();
    }

    // 2️⃣ Get event document (to delete image from storage)
    final eventDoc = await _db.collection('events').doc(eventId).get();

    if (eventDoc.exists) {
      final imageUrl = eventDoc['imageUrl'];

      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // ignore if image not found
        }
      }
    }

    // 3️⃣ Delete event
    await _db.collection('events').doc(eventId).delete();
  }
}
