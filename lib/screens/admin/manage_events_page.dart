import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/event_service.dart';

class ManageEventsPage extends StatelessWidget {
  const ManageEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: EventService().getEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Events",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, i) {
                  final e = events[i];

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
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e['title'],
                            style: const TextStyle(
                                fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore
                                .instance
                                .collection('events')
                                .doc(e.id)
                                .delete();
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}