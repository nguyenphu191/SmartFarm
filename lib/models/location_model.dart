class LocationModel {
  final String id;
  final String name;
  final String description;
  final String area;
  final String seasonId;
  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.area,
    this.seasonId = "",
  });
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      area: json['area'] ?? "",
      seasonId: json['seasonId'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'seasonId': seasonId,
      'description': description,
      'area': area,
    };
  }
}
