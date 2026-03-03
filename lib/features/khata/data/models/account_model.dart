import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String name;
  final String trackingType;
  final double totalBudget;
  final String createdBy;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.trackingType,
    required this.totalBudget,
    required this.createdBy,
    required this.createdAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map, String id) {
    return AccountModel(
      id: id,
      name: map['name'] ?? '',
      trackingType: map['trackingType'] ?? 'monthly',
      totalBudget: (map['totalBudget'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'trackingType': trackingType,
      'totalBudget': totalBudget,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AccountModel copyWith({
    String? name,
    String? trackingType,
    double? totalBudget,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      trackingType: trackingType ?? this.trackingType,
      totalBudget: totalBudget ?? this.totalBudget,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
