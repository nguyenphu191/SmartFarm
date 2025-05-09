class PlantModel {
  String? id;
  String? name;
  String? image;
  String? note;
  String? status;

  PlantModel({
    this.id,
    this.name,
    this.image,
    this.note,
    this.status,
  });

  PlantModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? "";
    name = json['name'] ?? "";
    image = json['image'] ?? "";
    note = json['note'] ?? "";
    status = json['status'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['note'] = note;
    return data;
  }
}
