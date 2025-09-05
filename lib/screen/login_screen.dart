import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:maria_pitanga/services/auth_service.dart';
import 'package:maria_pitanga/services/secure_storage.dart';
import 'package:maria_pitanga/utils/base64_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    SecureStorageService secureStorageService = SecureStorageService();
    final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://maria-pitanga-e5e82-default-rtdb.europe-west1.firebasedatabase.app",
    ).ref("auth_data");
    final TextEditingController emailResetPasswordController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();

    void showResetPasswordDialog() {
      Get.defaultDialog(
        title: "Esqueceu a senha?",
        content: Form(
          key: formKey,
          child: Column(
            children: [
              Text("Informe o e-mail usado no registo."),
              SizedBox(height: 5),
              TextFormField(
                controller: emailResetPasswordController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O e-mail é obrigatório";
                  }
                  // Regex simples para validar e-mail
                  if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(value)) {
                    return "Digite um e-mail válido";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        textConfirm: "Sim",
        textCancel: "Não",
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (formKey.currentState!.validate()) {
            authService
                .sendResetEmail(emailResetPasswordController.text.trim())
                .then(
                  (data) => Get.snackbar(
                    "Link de redefinição de senha",
                    data ??
                        "Se o e-mail existir, você vai receber um link de redefinição de senha.",
                    backgroundColor: Colors.purple,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 10),
                  ),
                );
            Get.back(); // fecha o dialog
            emailResetPasswordController.clear();
            formKey.currentState!.reset();
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Added to ensure content scrolls if needed
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circle with image at the top center
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage(
                      'assets/images/maria.jpeg',
                    ), // Make sure you have this image in your assets
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Bem-vindo de volta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    onPressed: () async {
                      try {
                        await authService
                            .login(
                              emailController.text,
                              passwordController.text,
                            )
                            .then((value) async {
                              if (value != null) {
                                secureStorageService.addNewItem(
                                  "email",
                                  value.user?.email ?? '',
                                );
                                await dbRef
                                    .child(
                                      Base64Utils.encode(
                                        value.user?.email ?? '',
                                      ),
                                    )
                                    .get()
                                    .then((snapshot) {
                                      try {
                                        if (snapshot.exists) {
                                          secureStorageService.addNewItem(
                                            "phone",
                                            snapshot.child("phone").value
                                                as String,
                                          );
                                        }
                                        if (value.user?.email ==
                                            "mariapitangacoimbra@gmail.com") {
                                          Get.offNamed('/card_adm');
                                        } else {
                                          Get.offNamed('/card');
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              "Erro ao fazer login",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                        debugPrint(
                                          'Error retrieving phone: $e',
                                        );
                                      }
                                    });
                              }
                            });
                      } on FirebaseException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Erro ao fazer login",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        debugPrint('FirebaseException: ${e.message}');
                      }
                    },
                    child: Text(
                      'Entrar',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: showResetPasswordDialog,
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/sign_up'),
                  child: Text(
                    'É novo por aqui? Crie uma conta',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
