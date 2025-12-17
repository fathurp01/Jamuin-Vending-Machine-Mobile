class VendingMachine {
  const VendingMachine({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    required this.status,
    required this.currentTemperature,
    required this.currentHumidity,
    required this.lastOnline,
    this.lat,
    this.lng,
  });

  final String id;
  final String code;
  final String name;
  final String location;
  final String status;
  final double? currentTemperature;
  final double? currentHumidity;
  final DateTime? lastOnline;

  /// Optional coordinates. Backend currently does not provide this.
  final double? lat;
  final double? lng;

  bool get hasCoordinates => lat != null && lng != null;

  factory VendingMachine.fromJson(Map<String, Object?> json) {
    final id = ((json['id'] as num?) ?? 0).toInt().toString();
    final status = ((json['status'] as String?) ?? '').trim();

    double? toDouble(Object? v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? toDateTime(Object? v) {
      if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return VendingMachine(
      id: id,
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      status: status,
      currentTemperature: toDouble(json['currentTemperature']),
      currentHumidity: toDouble(json['currentHumidity']),
      lastOnline: toDateTime(json['lastOnline']),
      lat: toDouble(json['lat']),
      lng: toDouble(json['lng']),
    );
  }
}
