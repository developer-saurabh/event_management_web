import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import '../../../services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Events",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder(
            stream: EventService().getEvents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final myEvents =
                  snapshot.data!.docs
                      .where((e) => e['organizerId'] == uid)
                      .toList();

              if (myEvents.isEmpty) {
                return const Center(child: Text("No events created yet"));
              }

              return ListView.builder(
                itemCount: myEvents.length,
                itemBuilder: (context, i) {
                  final e = myEvents[i];

                  final int ticketLimit = e['ticketLimit'] ?? 0;
                  final int ticketsSold = e['ticketsSold'] ?? 0;
                  final double progress =
                      ticketLimit == 0 ? 0 : ticketsSold / ticketLimit;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.black12),
                      ],
                    ),
                    child: Row(
                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImageNetwork(
                            width: 120,
                            height: 100,
                            fitWeb: BoxFitWeb.cover,
                            image: e['imageUrl'],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text("Date: ${e['date']}"),
                              const SizedBox(height: 10),

                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                              ),
                              const SizedBox(height: 5),
                              Text("$ticketsSold / $ticketLimit tickets sold"),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // ACTIONS
                        Column(
                          children: [
                            // IconButton(
                            //   icon: const Icon(Icons.visibility),
                            //   onPressed: () => _showBookings(context, e.id),
                            // ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                EventService().deleteEvent(e.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBookings(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Bookings"),
            content: SizedBox(
              width: 400,
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: EventService().getBookings(eventId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final bookings = snapshot.data!.docs;

                  if (bookings.isEmpty) {
                    return const Center(child: Text("No bookings yet"));
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (_, i) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(bookings[i]['userId']),
                      );
                    },
                  );
                },
              ),
            ),
          ),
    );
  }
}
