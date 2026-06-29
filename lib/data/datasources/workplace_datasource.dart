import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/data/models/workplace_model.dart';

class WorkplaceDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Documento único: workplace_config/main
  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection(FirestoreConstants.workplaceConfig).doc('main');

  Future<WorkplaceModel?> getWorkplace() async {
    final snap = await _doc.get();
    if (!snap.exists) return null;
    return WorkplaceModel.fromFirestore(snap);
  }

  Future<void> saveWorkplace(WorkplaceModel workplace) =>
      _doc.set(workplace.toMap());

  Stream<WorkplaceModel?> watchWorkplace() => _doc.snapshots().map((snap) {
        if (!snap.exists) return null;
        return WorkplaceModel.fromFirestore(snap);
      });
}