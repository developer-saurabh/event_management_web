import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../models/event_model.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .snapshots(), // removed orderBy for now
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }

        if (bookingSnapshot.hasError) {
          return Center(
              child: Text("Error: ${bookingSnapshot.error}"));
        }

        if (!bookingSnapshot.hasData ||
            bookingSnapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("No bookings found"));
        }

        final bookings = bookingSnapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "All Bookings",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];

                  final userId = booking['userId'];
                  final eventId = booking['eventId'];
                  final timestamp =
                      booking['timestamp'] as Timestamp?;

                  return FutureBuilder(
                    future:
                        _fetchUserAndEvent(userId, eventId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData) {
                        return const SizedBox();
                      }

                      final user =
                          snapshot.data!['user'] as UserModel?;
                      final event =
                          snapshot.data!['event']
                              as EventModel?;

                      if (user == null || event == null) {
                        return const SizedBox();
                      }

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 20),
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(user.email,
                                style: const TextStyle(
                                    color: Colors.grey)),
                            const SizedBox(height: 15),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(event.title,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w600)),
                            const SizedBox(height: 5),
                            Text("📅 ${event.date}",
                                style: const TextStyle(
                                    color: Colors.grey)),
                            const SizedBox(height: 5),
                            Text("💰 ₹${event.price}",
                                style: const TextStyle(
                                    color: Colors.grey)),
                            const SizedBox(height: 10),
                            if (timestamp != null)
                              Text(
                                "🕒 ${timestamp.toDate()}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchUserAndEvent(
      String userId, String eventId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (!userDoc.exists || !eventDoc.exists) {
        return {};
      }

      final user = UserModel.fromMap(
          userDoc.data()!, userDoc.id);

      final event = EventModel.fromMap(
          eventDoc.data()!, eventDoc.id);

      return {
        "user": user,
        "event": event,
      };
    } catch (e) {
      print("Error fetching data: $e");
      return {};
    }
  }
}