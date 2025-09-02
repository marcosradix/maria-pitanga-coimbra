import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:maria_pitanga/model/card_model.dart';
import 'package:maria_pitanga/model/my_card_model.dart';

class LoyaltyCardAdmScreen extends StatefulWidget {
  const LoyaltyCardAdmScreen({super.key});

  @override
  State<LoyaltyCardAdmScreen> createState() => _LoyaltyCardAdmScreenState();
}

class _LoyaltyCardAdmScreenState extends State<LoyaltyCardAdmScreen> {
  // 10 boxes total
  List<CardModel> stamps = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://maria-pitanga-e5e82-default-rtdb.europe-west1.firebasedatabase.app",
  ).ref("cards");

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

  // controllers
  final TextEditingController priceController = TextEditingController();
  final TextEditingController gramsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  late MyCardModel cardData;

  @override
  void initState() {
    if (stamps.isEmpty) {
      stamps = List.generate(
        10,
        (index) =>
            CardModel(stamped: false, price: null, grams: null, index: index),
      );
      cardData = MyCardModel(stamps: stamps, active: false, id: null);
    }
    super.initState();
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    final snapshot = await _dbRef.child(searchController.text).get();
    if (snapshot.value != null && snapshot.exists) {
      cardData = MyCardModel.fromJson(jsonDecode(jsonEncode(snapshot.value)));
      setState(() {
        stamps = cardData.stamps;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Usuário ${searchController.text} não encontrado.",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      stamps = List.generate(
        10,
        (index) =>
            CardModel(stamped: false, price: null, grams: null, index: index),
      );
      cardData = MyCardModel(stamps: stamps, active: false, id: null);
      throw Exception("Card data not found for id: ${searchController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: IconButton(
              tooltip: "Salvar",
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                _dbRef
                    .child(searchController.text)
                    .set(
                      cardData
                          .copyWith(
                            stamps: stamps,
                            active: true,
                            id: DateTime.now().millisecondsSinceEpoch,
                          )
                          .toJson(),
                    );

                priceController.clear();
                gramsController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.purple,
                    content: Text(
                      "Salvo! Preço: €${priceController.text}, Gramas: ${gramsController.text}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save, size: 30),
              color: Colors.white,
            ),
          ),
          //
        ],
        centerTitle: true,
        title: const Text(
          "Cartão Fidelidade",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Reiniciar",
        onPressed: () {
          setState(() {
            stamps = List.generate(
              10,
              (index) => CardModel(
                stamped: false,
                price: null,
                grams: null,
                index: index,
              ),
            );
            _dbRef
                .child(searchController.text)
                .set(cardData.copyWith(stamps: stamps).toJson());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.purple,
                content: Text(
                  "Cartão reiniciado e pronto para novos carimbos!",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          });
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                "Preencha seu cartão fidelidade e a cada 10€ de consumo receba um carimbo! "
                "Ao completar, poste e marque nossa loja em sua rede social para ganhar 300ml",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // 🔍 Campo de busca
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) async {
                      if (value.length == 9) {
                        try {
                          await init();
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          log("Error initializing search: ${e.toString()}");
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Buscar...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔄 Loading indicator
              if (isLoading) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),

              // 🔲 Grid de carimbos
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    minHeight: 300,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: texts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 por linha
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      bool stamped = stamps[index].stamped!;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            stamps[index] = stamps[index].copyWith(
                              stamped: !stamped,
                              price: int.tryParse(priceController.text),
                              grams: int.tryParse(gramsController.text),
                            );
                          });
                        },
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
                                      const Icon(
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
              const SizedBox(height: 10),

              // 🔢 Inputs + Rodapé
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Preço (€)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: gramsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Peso (g)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: const Text(
                  "Maria Pitanga",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Av. João das Regras, 139\n3040-256 Coimbra, Portugal",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Text(
                  "@mariapitangacoimbra | +351 926 434 534",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
