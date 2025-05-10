class CarePlanModel {
  final String id;
  final String type;
  final String note;
  final String date;
  final String seasonId;
  final String locationId;
  final String plantId;

  CarePlanModel({
    required this.id,
    required this.type,
    required this.note,
    required this.date,
    required this.seasonId,
    required this.locationId,
    required this.plantId,
  });
  factory CarePlanModel.fromJson(Map<String, dynamic> json) {
    return CarePlanModel(
      id: json['_id'] ?? "",
      type: json['type'] ?? "",
      note: json['note'] ?? "",
      date: json['date'] ?? "",
      seasonId: json['seasonId'] ?? "",
      locationId: json['locationId'] ?? "",
      plantId: json['plantId'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'note': note,
      'date': date,
      'seasonId': seasonId,
      'locationId': locationId,
      'plantId': plantId,
    };
  }
}
