import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdmAuthGuard extends GetMiddleware {
  @override
  int? priority = 1;

  @override
  RouteSettings? redirect(String? route) {
    bool isAdmin =
        FirebaseAuth.instance.currentUser?.email ==
        "mariapitangacoimbra@gmail.com";
    if (!isAdmin) {
      return RouteSettings(name: '/card');
    }
    return null;
  }
}
