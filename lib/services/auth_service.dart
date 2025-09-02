import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      localStorage.removeItem("email");
      localStorage.removeItem("phone");
    } catch (e) {
      log('Logout error: $e');
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log('Registration error: $e');
      return null;
    }
  }
}
