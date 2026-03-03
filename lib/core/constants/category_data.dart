import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CategoryData {
  CategoryData._();

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(name: 'Food', icon: Icons.restaurant, color: Color(0xFFEF4444)),
    CategoryItem(name: 'Transport', icon: Icons.directions_car, color: Color(0xFF3B82F6)),
    CategoryItem(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFFF97316)),
    CategoryItem(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFF8B5CF6)),
    CategoryItem(name: 'Entertainment', icon: Icons.movie, color: Color(0xFFEC4899)),
    CategoryItem(name: 'Health', icon: Icons.medical_services, color: Color(0xFF10B981)),
    CategoryItem(name: 'Education', icon: Icons.school, color: Color(0xFF06B6D4)),
    CategoryItem(name: 'Rent', icon: Icons.home, color: Color(0xFF6366F1)),
    CategoryItem(name: 'Groceries', icon: Icons.local_grocery_store, color: Color(0xFF22C55E)),
    CategoryItem(name: 'Utilities', icon: Icons.bolt, color: Color(0xFFF59E0B)),
    CategoryItem(name: 'Salary', icon: Icons.attach_money, color: Color(0xFF14B8A6)),
    CategoryItem(name: 'Gift', icon: Icons.card_giftcard, color: Color(0xFFE11D48)),
    CategoryItem(name: 'Travel', icon: Icons.flight, color: Color(0xFF0EA5E9)),
    CategoryItem(name: 'Other', icon: Icons.more_horiz, color: Color(0xFF64748B)),
  ];

  static CategoryItem getCategoryByName(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => defaultCategories.last,
    );
  }
}
