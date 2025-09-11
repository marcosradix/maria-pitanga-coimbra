import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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

  Future<void> onDeletePressed() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log(
          'The user must reauthenticate before this operation can be executed.',
        );
      } else {
        log('Delete account error: $e');
      }
    }
  }

  Future<String?> sendResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail inválido';
        case 'user-not-found':
          // Consider a generic message to avoid user enumeration:
          return 'Se o e-mail existe, você vai receber um link de reset de senha.';
        case 'too-many-requests':
          return 'Tente novamente mais tarde, você já tentou mauitas vezes.';
        default:
          return 'Algo deu errado, tente novamente.';
      }
    }
  }
}
