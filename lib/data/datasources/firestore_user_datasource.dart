import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/core/constants/firestore_constants.dart';
import 'package:ponto_eletronico/data/models/user_model.dart';

class FirestoreUserDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(FirestoreConstants.users);

  Future<UserModel> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    return UserModel.fromFirestore(doc);
  }

  Future<String> getRole(String uid) async {
    final doc = await _col.doc(uid).get();
    return doc['role'] as String;
  }

  Future<List<UserModel>> getAllEmployees() async {
    final snap = await _col.where('role', isEqualTo: 'employee').get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  Future<void> saveUser(UserModel user) =>
      _col.doc(user.uid).set(user.toMap());

  Future<void> deleteEmployee(String uid) => _col.doc(uid).delete();
}