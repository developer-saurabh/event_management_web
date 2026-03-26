import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  // ✅ Check if user already voted
  Future<bool> hasVoted(String eventId) async {
    final res =
        await _db
            .collection('votes')
            .where('userId', isEqualTo: uid)
            .where('eventId', isEqualTo: eventId)
            .get();

    return res.docs.isNotEmpty;
  }

  // ✅ Vote
  Future<void> vote(String eventId) async {
    final already = await hasVoted(eventId);

    if (already) throw Exception("Already voted");

    final batch = _db.batch();

    // Add vote
    final voteRef = _db.collection('votes').doc();
    batch.set(voteRef, {
      'userId': uid,
      'eventId': eventId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment count
    final eventRef = _db.collection('events').doc(eventId);
    batch.update(eventRef, {'votes': FieldValue.increment(1)});

    await batch.commit();
  }
}
