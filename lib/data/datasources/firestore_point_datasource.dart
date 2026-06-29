import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';
import 'package:ponto_eletronico/data/models/time_record_model.dart';

class FirestorePointDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestoreConstants.timeRecords);

  // ── Escrita ──────────────────────────────────────────────────────────────

  Future<void> addRecord(TimeRecordModel record) => _col.add(record.toMap());

  Future<void> updateRecord(TimeRecordModel record) =>
      _col.doc(record.id).update(record.toMap());

  // ── Leitura pontual (Future) ─────────────────────────────────────────────

  Future<TimeRecordModel?> getTodayRecord(String userId) async {
    final now = DateTime.now();
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now.startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now.endOfDay))
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return TimeRecordModel.fromFirestore(snap.docs.first);
  }

  Future<List<TimeRecordModel>> getMonthlyRecords(
    String userId, {
    required int month,
    required int year,
  }) async {
    final start = DateTime(year, month);
    final end = start.startOfNextMonth;

    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    return snap.docs.map(TimeRecordModel.fromFirestore).toList();
  }

  // ── Streams em tempo real (para o gerente) ───────────────────────────────

  /// Emite a lista de registros de hoje sempre que qualquer funcionário
  /// bate o ponto — sem precisar recarregar manualmente.
  Stream<List<TimeRecordModel>> watchTodayRecords() {
    final now = DateTime.now();
    return _col
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(now.startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now.endOfDay))
        .snapshots()
        .map((snap) =>
            snap.docs.map(TimeRecordModel.fromFirestore).toList());
  }

  /// Emite os registros do mês sempre que há alguma alteração.
  Stream<List<TimeRecordModel>> watchMonthlyRecords({
    required int month,
    required int year,
  }) {
    final start = DateTime(year, month);
    final end = start.startOfNextMonth;

    return _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map(TimeRecordModel.fromFirestore).toList());
  }
}