import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {
  @override
  int? priority = 1;

  @override
  RouteSettings? redirect(String? route) {
    bool isLogged = FirebaseAuth.instance.currentUser?.email != null;
    if (!isLogged) {
      return RouteSettings(name: '/login');
    }
    return null;
  }
}
