class GeoFence {
  final String name;
  final String radius;

  GeoFence({
    this.name,
    this.radius,
  });

  factory GeoFence.fromJson(Map<String, dynamic> json) {
    return GeoFence(
      name: json["name"],
      radius: json["radius"],
    );
  }
}
