class LocationModel {
  final double lat;
  final double long;
  final String name;

  LocationModel({required this.lat, required this.long, required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: json['lat'],
      long: json['lon'],
      name: json['tags']['name'] ?? "NULL",
    );
  }
}
