import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_network/image_network.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/booking_service.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;

  Future<void> bookEvent(
      String eventId, int ticketsSold, int ticketLimit) async {
    if (ticketsSold >= ticketLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Sold Out")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await BookingService().bookEvent(uid, eventId);

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
        "ticketsSold": FieldValue.increment(1),
      });

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Successful 🎉")),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final e = snapshot.data!;
          final int ticketsSold = e['ticketsSold'] ?? 0;
          final int ticketLimit = e['ticketLimit'] ?? 0;
          final bool isSoldOut = ticketsSold >= ticketLimit;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ IMPORTANT FIX: IgnorePointer added
                LayoutBuilder(
                  builder: (context, constraints) {
                    return IgnorePointer(
                      child: ImageNetwork(
                        image: e['imageUrl'],
                        height: 400,
                        width: constraints.maxWidth,
                        fitWeb: BoxFitWeb.cover,
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title'],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "₹ ${e['price']}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        e['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (isSoldOut || isLoading)
                              ? null
                              : () => bookEvent(
                                    widget.eventId,
                                    ticketsSold,
                                    ticketLimit,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSoldOut
                                ? Colors.grey
                                : Colors.deepPurple,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isSoldOut ? "Sold Out" : "Book Now",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}