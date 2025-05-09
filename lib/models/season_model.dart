class SeasonModel {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  SeasonModel({
    this.id = '',
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    DateTime? start;
    DateTime? end;

    try {
      start = json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null;
    } catch (_) {}

    try {
      end = json['end_date'] != null ? DateTime.parse(json['end_date']) : null;
    } catch (_) {}

    bool active = end != null ? end.isAfter(DateTime.now()) : true;

    return SeasonModel(
      id: json['_id'] ?? 'Unknown',
      name: json['name'] ?? 'Unknown',
      startDate: start,
      endDate: end,
      isActive: active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
