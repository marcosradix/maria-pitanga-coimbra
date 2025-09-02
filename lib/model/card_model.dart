class CardModel {
  CardModel({
    required this.stamped,
    required this.price,
    required this.grams,
    required this.index,
  });

  final bool? stamped;
  final int? price;
  final int? grams;
  final int? index;

  CardModel copyWith({bool? stamped, int? price, int? grams, int? index}) {
    return CardModel(
      stamped: stamped ?? this.stamped,
      price: price ?? this.price,
      grams: grams ?? this.grams,
      index: index ?? this.index,
    );
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      stamped: json["stamped"],
      price: json["price"],
      grams: json["grams"],
      index: json["index"],
    );
  }
  Map<String, dynamic> toJson() => {
    "stamped": stamped,
    "price": price,
    "grams": grams,
    "index": index,
  };
  @override
  String toString() {
    return "$stamped, $price, $grams, $index";
  }
}
