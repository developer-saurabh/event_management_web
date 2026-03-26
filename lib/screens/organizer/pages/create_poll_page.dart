import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePollPage extends StatefulWidget {
  final String? eventId;

  const CreatePollPage({super.key, this.eventId});

  @override
  State<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void addOption() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  Future<void> createPoll() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final options =
        optionControllers.map((c) => {"text": c.text, "votes": 0}).toList();

    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('polls')
        .add({
          "question": questionController.text,
          "options": options,
          "voters": [],
          "createdBy": uid,
          "createdAt": Timestamp.now(),
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Poll')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            const SizedBox(height: 20),

            ...optionControllers.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: c,
                  decoration: const InputDecoration(labelText: "Option"),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: addOption,
              child: const Text("Add Option"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: createPoll,
              child: const Text("Create Poll"),
            ),
          ],
        ),
      ),
    );
  }
}
