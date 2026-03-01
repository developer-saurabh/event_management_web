import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> signup(
      String name, String email, String password, String role) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}