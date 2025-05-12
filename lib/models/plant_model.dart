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
  String? unit;
  String? rating;
  String? seasonId;
  String? locationId;

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
    this.unit,
    this.rating,
    this.seasonId,
    this.locationId,
  });

  PlantModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? "";
    name = json['name'] ?? "";
    image = json['img'] ?? "";
    note = json['note'] ?? "";
    status = json['status'] ?? "";
    sysImg = json['img'] ?? "";
    startDate = json['startdate'] ?? "";
    endDate = json['plantingDate'] ?? "";
    address = json['address'] ?? "";

    // Kiểm tra cẩn thận json['yield'] có phải là Map không
    if (json['yield'] != null && json['yield'] is Map) {
      Map<String, dynamic> yieldData = json['yield'] as Map<String, dynamic>;
      unit = yieldData['unit'] ?? "";
    } else {
      unit = "";
    }

    // Kiểm tra cẩn thận json['quality'] có phải là Map không
    if (json['quality'] != null && json['quality'] is Map) {
      Map<String, dynamic> qualityData =
          json['quality'] as Map<String, dynamic>;
      rating = qualityData['rating'] ?? "";
    } else {
      rating = "";
    }
    if (json['seasonId'] != null && json['seasonId'] is Map) {
      Map<String, dynamic> seasonData =
          json['seasonId'] as Map<String, dynamic>;
      seasonId = seasonData['_id'] ?? "";
    } else {
      seasonId = "";
    }
    if (json['locationId'] != null && json['locationId'] is Map) {
      Map<String, dynamic> locationData =
          json['locationId'] as Map<String, dynamic>;
      locationId = locationData['_id'] ?? "";
    } else {
      locationId = "";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['note'] = note;
    return data;
  }

  @override
  String toString() {
    return 'PlantModel{id: $id, name: $name, image: $image, note: $note, status: $status, startDate: $startDate, endDate: $endDate, address: $address}';
  }
}
