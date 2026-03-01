import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final password = TextEditingController();
  String selectedRole = "user";

  Future<void> login() async {
    await AuthService().login(email.text, password.text);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account not found in database")),
      );
      return;
    }

    final role = doc.data()!['role'];

    if (role != selectedRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong role selected")),
      );
      return;
    }

    if (role == 'admin') {
      context.go('/admin');
    } else if (role == 'organizer') {
      context.go('/organizer');
    } else {
      context.go('/user');
    }
  }

  Widget roleTab(String role, IconData icon) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.black),
              const SizedBox(height: 5),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                    color:
                        isSelected ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 20,
                  color: Colors.black12)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Event Management",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              Row(
                children: [
                  roleTab("user", Icons.person),
                  const SizedBox(width: 10),
                  roleTab("organizer", Icons.event),
                  const SizedBox(width: 10),
                  roleTab("admin", Icons.admin_panel_settings),
                ],
              ),

              const SizedBox(height: 25),

              TextField(
                controller: email,
                decoration:
                    const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.deepPurple),
                  child: const Text("Login"),
                ),
              ),

              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text("Create Account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}