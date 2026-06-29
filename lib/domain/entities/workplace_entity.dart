class WorkplaceEntity {
  final double latitude;
  final double longitude;
  final double radiusMeters; // raio máximo permitido
  final String name;         // nome do local ex: "Lanchonete Central"

  const WorkplaceEntity({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.radiusMeters = 200,
  });
}