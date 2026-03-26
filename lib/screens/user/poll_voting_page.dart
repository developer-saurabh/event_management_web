import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PollVotingPage extends StatelessWidget {
  final String eventId;

  const PollVotingPage({super.key, required this.eventId});

  Future<void> vote(String pollId, int index, List options, List voters) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (voters.contains(uid)) return;

    options[index]['votes'] += 1;
    voters.add(uid);

    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('polls')
        .doc(pollId)
        .update({"options": options, "voters": voters});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Vote")),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .collection('polls')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final polls = snapshot.data!.docs;

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, i) {
              final p = polls[i];
              final options = List.from(p['options']);
              final voters = List.from(p['voters']);

              final hasVoted = voters.contains(uid);

              return Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
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

                      const SizedBox(height: 10),

                      ...List.generate(options.length, (index) {
                        return ListTile(
                          title: Text(options[index]['text']),
                          trailing: Text("${options[index]['votes']} votes"),
                          onTap:
                              hasVoted
                                  ? null
                                  : () => vote(p.id, index, options, voters),
                        );
                      }),

                      if (hasVoted)
                        const Text(
                          "You already voted",
                          style: TextStyle(color: Colors.red),
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
