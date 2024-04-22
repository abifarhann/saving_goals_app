
class SavingModel {
  final int? savingId;
  final String goalTitle;
  final int totalAmount;
  final DateTime deadline;
  final int amountSaved;
  final String frequency;
  final int nominal;
  bool isArchived = false;

  SavingModel({
    this.savingId,
    required this.goalTitle,
    required this.totalAmount,
    required this.deadline,
    required this.amountSaved,
    required this.frequency,
    required this.nominal,
    this.isArchived = false,
  });

    factory SavingModel.fromMap(Map<String, dynamic> json) => SavingModel(
        savingId: json["savingId"],
        goalTitle: json["goalTitle"],
        totalAmount: json["totalAmount"],
        deadline: DateTime.parse(json["deadline"]),
        amountSaved: json["amountSaved"],
        frequency: json["frequency"],
        nominal: json["nominal"],
        isArchived: json["isArchived"] == 1,
      );

    Map<String, dynamic> toMap() => {
        "savingId": savingId,
        "goalTitle": goalTitle,
        "totalAmount": totalAmount,
        "deadline": "${deadline.year.toString().padLeft(4, '0')}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}",
        "amountSaved": amountSaved,
        "frequency": frequency,
        "nominal": nominal,
        "isArchived": isArchived ? 1 : 0,
      };
}
