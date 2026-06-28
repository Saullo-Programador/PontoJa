import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/core/utils/date_utils.dart';
import 'package:ponto_eletronico/data/models/time_record_model.dart';

class FirestorePointDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestoreConstants.timeRecords);

  Future<void> addRecord(TimeRecordModel record) =>
      _col.add(record.toMap());

  Future<void> updateRecord(TimeRecordModel record) =>
      _col.doc(record.id).update(record.toMap());

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

  Future<List<TimeRecordModel>> getAllTodayRecords() async {
    final now = DateTime.now();
    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now.startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now.endOfDay))
        .get();

    return snap.docs.map(TimeRecordModel.fromFirestore).toList();
  }

  Future<List<TimeRecordModel>> getAllMonthlyRecords({
    required int month,
    required int year,
  }) async {
    final start = DateTime(year, month);
    final end = start.startOfNextMonth;

    final snap = await _col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .get();

    return snap.docs.map(TimeRecordModel.fromFirestore).toList();
  }
}