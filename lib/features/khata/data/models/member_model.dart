import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;

  MemberModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberModel(
      userId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'viewer',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  bool get isOwner => role == 'owner';
  bool get isEditor => role == 'editor' || role == 'owner';
  bool get isViewer => role == 'viewer';
}
