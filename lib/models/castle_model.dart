class CastleModel {
  final String id;
  final String nameKey;
  final double latitude;
  final double longitude;
  final String area;

  CastleModel({required this.id, required this.nameKey, required this.latitude, required this.longitude, required this.area});

  Map<String, dynamic> toMap() => {'id': id, 'nameKey': nameKey, 'latitude': latitude, 'longitude': longitude, 'area': area};
}
