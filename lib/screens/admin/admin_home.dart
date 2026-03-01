import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;
        int totalEvents = events.length;

        int totalTicketsSold = 0;
        double totalRevenue = 0;

        for (var e in events) {
          int sold = e['ticketsSold'] ?? 0;
          double price = (e['price'] as num).toDouble();

          totalTicketsSold += sold;
          totalRevenue += sold * price;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _kpiCard("Total Events", totalEvents.toString()),
                const SizedBox(width: 20),
                _kpiCard("Tickets Sold", totalTicketsSold.toString()),
                const SizedBox(width: 20),
                _kpiCard(
                    "Revenue", "₹ ${totalRevenue.toStringAsFixed(0)}"),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _kpiCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}