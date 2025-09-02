import 'package:maria_pitanga/model/card_model.dart';

class MyCardModel {
  MyCardModel({required this.stamps, required this.active, required this.id});

  final List<CardModel> stamps;
  final bool? active;
  final int? id;

  MyCardModel copyWith({List<CardModel>? stamps, bool? active, int? id}) {
    return MyCardModel(
      stamps: stamps ?? this.stamps,
      active: active ?? this.active,
      id: id ?? this.id,
    );
  }

  factory MyCardModel.fromJson(Map<String, dynamic> json) {
    return MyCardModel(
      stamps: json["stamps"] == null
          ? []
          : List<CardModel>.from(
              json["stamps"]!.map((x) => CardModel.fromJson(x)),
            ),
      active: json["active"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "stamps": stamps.map((x) => x.toJson()).toList(),
    "active": active,
    "id": id,
  };

  @override
  String toString() {
    return "$stamps, $active, $id";
  }
}
