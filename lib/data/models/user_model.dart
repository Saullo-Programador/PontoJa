import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        uid: entity.uid,
        name: entity.name,
        email: entity.email,
        role: entity.role,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
      };
}