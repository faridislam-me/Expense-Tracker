import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String email;
  final String role;
  final String invitedBy;
  final String accountName;
  final String accountId;
  final String status;
  final DateTime createdAt;

  InviteModel({
    required this.id,
    required this.email,
    required this.role,
    required this.invitedBy,
    required this.accountName,
    required this.accountId,
    required this.status,
    required this.createdAt,
  });

  factory InviteModel.fromMap(Map<String, dynamic> map, String id) {
    return InviteModel(
      id: id,
      email: map['email'] ?? '',
      role: map['role'] ?? 'viewer',
      invitedBy: map['invitedBy'] ?? '',
      accountName: map['accountName'] ?? '',
      accountId: map['accountId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'invitedBy': invitedBy,
      'accountName': accountName,
      'accountId': accountId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
}
