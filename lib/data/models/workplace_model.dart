import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/workplace_entity.dart';

class WorkplaceModel extends WorkplaceEntity {
  const WorkplaceModel({
    required super.latitude,
    required super.longitude,
    required super.name,
    super.radiusMeters,
  });

  factory WorkplaceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkplaceModel(
      latitude:     (d['latitude']     as num).toDouble(),
      longitude:    (d['longitude']    as num).toDouble(),
      name:         d['name']          as String,
      radiusMeters: (d['radiusMeters'] as num?)?.toDouble() ?? 200,
    );
  }

  factory WorkplaceModel.fromEntity(WorkplaceEntity e) => WorkplaceModel(
        latitude:     e.latitude,
        longitude:    e.longitude,
        name:         e.name,
        radiusMeters: e.radiusMeters,
      );

  Map<String, dynamic> toMap() => {
        'latitude':     latitude,
        'longitude':    longitude,
        'name':         name,
        'radiusMeters': radiusMeters,
      };
}