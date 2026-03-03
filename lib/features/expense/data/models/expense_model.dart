import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String addedBy;
  final String? monthKey;
  final String? receiptUrl;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.addedBy,
    this.monthKey,
    this.receiptUrl,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      addedBy: map['addedBy'] ?? '',
      monthKey: map['monthKey'],
      receiptUrl: map['receiptUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'addedBy': addedBy,
      'monthKey': monthKey,
      'receiptUrl': receiptUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ExpenseModel copyWith({
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? receiptUrl,
  }) {
    return ExpenseModel(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      addedBy: addedBy,
      monthKey: monthKey,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt,
    );
  }
}
