import 'package:flutter/material.dart';
import '../../../services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizerHome extends StatelessWidget {
  const OrganizerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        StreamBuilder(
          stream: EventService().getEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final myEvents = snapshot.data!.docs
                .where((e) =>
                    e['organizerId'] == uid)
                .toList();

            int totalEvents = myEvents.length;
            int totalTickets = 0;
            double totalRevenue = 0;

            for (var e in myEvents) {
              int sold = e['ticketsSold'] ?? 0;
              double price =
                  (e['price'] ?? 0).toDouble();

              totalTickets += sold;
              totalRevenue += sold * price;
            }

            return Row(
              children: [
                statCard(
                    "Total Events",
                    totalEvents.toString(),
                    Colors.blue),
                const SizedBox(width: 20),
                statCard(
                    "Tickets Sold",
                    totalTickets.toString(),
                    Colors.orange),
                const SizedBox(width: 20),
                statCard(
                    "Revenue",
                    "₹ ${totalRevenue.toStringAsFixed(0)}",
                    Colors.green),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget statCard(
      String title, String value, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              blurRadius: 12,
              color: Colors.black12)
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}