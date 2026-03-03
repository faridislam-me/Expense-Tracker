class ExpenseSummaryModel {
  final double totalExpenses;
  final double totalBudget;
  final Map<String, double> categoryTotals;
  final int expenseCount;

  ExpenseSummaryModel({
    required this.totalExpenses,
    required this.totalBudget,
    required this.categoryTotals,
    required this.expenseCount,
  });

  double get remaining => totalBudget - totalExpenses;
  double get progress => totalBudget > 0 ? (totalExpenses / totalBudget).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => totalExpenses > totalBudget;

  String get topCategory {
    if (categoryTotals.isEmpty) return 'None';
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
