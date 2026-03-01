import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_network/image_network.dart';
import '../../services/event_service.dart';
import 'package:go_router/go_router.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f172a),
        elevation: 0,
        title: const Text(
          "EventX",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          Expanded(child: _buildEventsSection()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search events...",
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xff1e293b),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
        stream: EventService().getEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs.where((e) {
            final title = e['title'].toString().toLowerCase();
            return title.contains(searchQuery);
          }).toList();

          if (events.isEmpty) {
            return const Center(
              child: Text(
                "No events found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 1000) crossAxisCount = 2;
              if (constraints.maxWidth < 600) crossAxisCount = 1;

              final cardWidth =
                  (constraints.maxWidth - ((crossAxisCount - 1) * 20)) /
                      crossAxisCount;

              return GridView.builder(
                itemCount: events.length,
                padding: const EdgeInsets.only(bottom: 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 320, // ✅ FIXED PROPER HEIGHT
                ),
                itemBuilder: (context, i) {
                  final e = events[i];

                  return HoverEventCard(
                    width: cardWidth,
                    event: e,
                    onCardTap: () {
                      context.go('/event/${e.id}');
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
///
/// HOVER CARD (Clean Compact Version)
///
////////////////////////////////////////////////////////////

class HoverEventCard extends StatefulWidget {
  final dynamic event;
  final double width;
  final VoidCallback onCardTap;

  const HoverEventCard({
    super.key,
    required this.event,
    required this.width,
    required this.onCardTap,
  });

  @override
  State<HoverEventCard> createState() => _HoverEventCardState();
}

class _HoverEventCardState extends State<HoverEventCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return MouseRegion(
      cursor: SystemMouseCursors.click, // ✅ Hand cursor
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isHovered)
              const BoxShadow(
                blurRadius: 25,
                color: Colors.black54,
              )
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // ✅ Entire card clickable
          onTap: widget.onCardTap,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: const Color(0xff1e293b),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Only required height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               ClipRRect(
  borderRadius:
      const BorderRadius.vertical(top: Radius.circular(20)),
  child: IgnorePointer( // 👈 IMPORTANT FIX
    child: ImageNetwork(
      image: e['imageUrl'],
      height: 200,
      width: widget.width,
      fitWeb: BoxFitWeb.cover,
    ),
  ),
),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹ ${e['price']}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}