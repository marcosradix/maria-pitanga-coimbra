import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:maria_pitanga/model/card_model.dart';
import 'package:maria_pitanga/model/my_card_model.dart';
import 'package:maria_pitanga/services/auth_service.dart';

class LoyaltyCardScreen extends StatefulWidget {
  const LoyaltyCardScreen({super.key});

  @override
  State<LoyaltyCardScreen> createState() => _LoyaltyCardScreenState();
}

class _LoyaltyCardScreenState extends State<LoyaltyCardScreen> {
  // 10 boxes total
  List<CardModel> stamps = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://maria-pitanga-e5e82-default-rtdb.europe-west1.firebasedatabase.app",
  ).ref("cards");
  late StreamSubscription<DatabaseEvent> _subscription;
  final String? phoneNumber = localStorage.getItem("phone");
  AuthService authService = AuthService();

  final List<String> texts = [
    "CURTI MUITO, SEMI",
    "BOM TE VER AQUI",
    "BOM DEMAIS, NÉ?!",
    "É MUUUITO BOM, NÉ?!",
    "METADE JÁ FOI...",
    "TEM SABOR VINDO AÍ DE PRESENTE",
    "JÁ É O SEU ESTILO DE VIDA!",
    "COMO É BOM TER VOCÊ POR AQUI COM A GENTE",
    "FALTA SÓ UM!",
    "VOCÊ GANHOU!",
  ];

  @override
  void initState() {
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      _subscription = _dbRef.child(phoneNumber ?? "").onValue.listen((
        DatabaseEvent event,
      ) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            MyCardModel cardData = MyCardModel.fromJson(
              jsonDecode(jsonEncode(data)),
            );
            setState(() {
              stamps = cardData.stamps;
            });
          });
        }
      });
    }

    if (stamps.isEmpty) {
      stamps = List.generate(
        10,
        (index) =>
            CardModel(stamped: false, price: null, grams: null, index: index),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Cartão Fidelidade",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () {
              authService.logout().then((_) {
                Get.toNamed("/login");
              });
            },
          ),
        ],

        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Preencha seu cartão fidelidade e a cada 10€ de consumo receba um carimbo! "
              "Ao completar, poste e marque nossa loja em sua rede social para ganhar 300ml",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: GridView.builder(
                    itemCount: texts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 per row
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      bool stamped = stamps[index].stamped!;
                      return InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: stamped ? Colors.blue[50] : Colors.white,
                          ),
                          child: Center(
                            child: stamped
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 40,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        "✔",
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      texts[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Maria Pitanga",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "R. Carlos Alberto Pinto de Abreu, 31\n3040-245 Coimbra, Portugal",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            const Text(
              "@mariapitangacoimbra | +351 926 434 534",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
