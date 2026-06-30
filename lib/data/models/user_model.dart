import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.username,
    required super.role,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final email = d['email'] as String;
    // Compatibilidade: se username não existe ainda, deriva do email
    final username = d['username'] as String? ??
        email.replaceAll('@ponto.app', '');
    return UserModel(
      uid:      doc.id,
      name:     d['name']     as String,
      email:    email,
      username: username,
      role:     d['role']     as String,
    );
  }

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        uid:      e.uid,
        name:     e.name,
        email:    e.email,
        username: e.username,
        role:     e.role,
      );

  Map<String, dynamic> toMap() => {
        'uid':      uid,
        'name':     name,
        'email':    email,
        'username': username,
        'role':     role,
      };
}