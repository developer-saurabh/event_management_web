import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  String selectedRole = "user";

  Future<void> signup() async {
    await AuthService()
        .signup(name.text, email.text, password.text, selectedRole);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account Created Successfully")),
    );

    context.go('/');
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
              const Text("Create Account",
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
                controller: name,
                decoration:
                    const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
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
                  onPressed: signup,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.deepPurple),
                  child: const Text("Signup"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}