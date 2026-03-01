import 'package:flutter/material.dart';
import 'pages/organizer_home.dart';
import 'pages/create_event_page.dart';
import 'pages/my_events_page.dart';
import '../../services/auth_service.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() =>
      _OrganizerDashboardState();
}

class _OrganizerDashboardState
    extends State<OrganizerDashboard> {
  int selectedIndex = 0;

  final pages = const [
    OrganizerHome(),
    CreateEventPage(),
    MyEventsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 250,
            color: const Color(0xff1e1e2f),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Organizer Panel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                sidebarItem(Icons.dashboard, "Dashboard", 0),
                sidebarItem(Icons.add_box, "Create Event", 1),
                sidebarItem(Icons.event_note, "My Events", 2),

                const Spacer(),

                ListTile(
                  leading: const Icon(Icons.logout,
                      color: Colors.white),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await AuthService().logout();
                  },
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Container(
              color: const Color(0xfff4f6fa),
              padding: const EdgeInsets.all(30),
              child: pages[selectedIndex],
            ),
          )
        ],
      ),
    );
  }

  Widget sidebarItem(
      IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading:
          Icon(icon, color: isSelected ? Colors.purple : Colors.white),
      title: Text(title,
          style: TextStyle(
              color:
                  isSelected ? Colors.purple : Colors.white)),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}