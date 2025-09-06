// ===== Modelo / Preços =====
import 'package:flutter/material.dart';

class Ingredient {
  final String name;
  final String emoji;
  final Color color;
  final int gramsPerAdd;
  final double euroPerGram;
  const Ingredient({
    required this.name,
    required this.emoji,
    required this.color,
    required this.gramsPerAdd,
    required this.euroPerGram,
  });
  double get pricePerAdd => gramsPerAdd * euroPerGram;
}
