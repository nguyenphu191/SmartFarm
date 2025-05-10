class PlantModel {
  String? id;
  String? name;
  String? image;
  String? sysImg;
  String? note;
  String? status;
  String? startDate;
  String? endDate;
  String? address;

  PlantModel({
    this.id,
    this.name,
    this.image,
    this.note,
    this.status,
    this.sysImg,
    this.startDate,
    this.endDate,
    this.address,
  });

  PlantModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? "";
    name = json['name'] ?? "";
    image = json['image'] ?? "";
    note = json['note'] ?? "";
    status = json['status'] ?? "";
    sysImg = json['defaultImage'] ?? "";
    startDate = json['startdate'] ?? "";
    endDate = json['plantingDate'] ?? "";
    address = json['address'] ?? "";
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
