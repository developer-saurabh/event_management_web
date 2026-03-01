import 'package:event_management_web/screens/admin/admin_home.dart';
import 'package:event_management_web/screens/admin/bookings_page.dart';
import 'package:event_management_web/screens/admin/manage_events_page.dart';
import 'package:event_management_web/screens/admin/users_page.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final pages = const [
    AdminHomePage(),
    ManageEventsPage(),
    BookingsPage(),
    UsersPage(),
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
                  "Admin Panel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                sidebarItem(Icons.dashboard, "Dashboard", 0),
                sidebarItem(Icons.event, "Manage Events", 1),
                sidebarItem(Icons.book_online, "Bookings", 2),
                // sidebarItem(Icons.people, "Users", 3),

                const Spacer(),

                ListTile(
                  leading:
                      const Icon(Icons.logout, color: Colors.white),
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

  Widget sidebarItem(IconData icon, String title, int index) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon,
          color: isSelected ? Colors.purple : Colors.white),
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