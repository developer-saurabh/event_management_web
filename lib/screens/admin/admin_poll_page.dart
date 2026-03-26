import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPollPage extends StatelessWidget {
  const AdminPollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Poll Management",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, i) {
                  final e = events[i];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      title: Text(e['title']),
                      subtitle: const Text("View Polls"),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EventPollDetailPage(
                                  eventId: e.id,
                                  eventTitle: e['title'],
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
///
/// EVENT POLL DETAIL PAGE (ADMIN VIEW)
///
////////////////////////////////////////////////////////////

class EventPollDetailPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const EventPollDetailPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Polls - $eventTitle")),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .collection('polls')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final polls = snapshot.data!.docs;

          if (polls.isEmpty) {
            return const Center(child: Text("No polls found"));
          }

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, i) {
              final p = polls[i];
              final options = List.from(p['options']);

              int totalVotes = 0;
              for (var o in options) {
                totalVotes += (o['votes'] as int);
              }

              return Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      ...options.map((o) {
                        double percent =
                            totalVotes == 0 ? 0 : (o['votes'] / totalVotes);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(o['text']),
                                Text("${o['votes']} votes"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }),

                      const Divider(),

                      Text(
                        "Total Votes: $totalVotes",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('events')
                                  .doc(eventId)
                                  .collection('polls')
                                  .doc(p.id)
                                  .delete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Delete Poll"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
