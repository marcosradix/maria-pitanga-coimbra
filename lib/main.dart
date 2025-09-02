import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:localstorage/localstorage.dart';
import 'package:maria_pitanga/firebase_options.dart';
import 'package:maria_pitanga/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:maria_pitanga/screen/login_screen.dart';

bool _isUserLogged = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() => debugPrint('FIREBASE INITIALIZED WEB==============>'));
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: "MariaPitangaCoimbra",
    ).whenComplete(() => debugPrint('FIREBASE INITIALIZED================>'));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppPages.routes,
      initialRoute: _isUserLogged ? null : Routes.INITIAL,
      debugShowCheckedModeBanner: false,
      title: 'Maria Pitanga Coimbra',
      theme: ThemeData(
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const LoginPage(),
    );
  }
}
