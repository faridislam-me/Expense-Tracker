class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';
  static const String appTagline = 'Track your expenses, manage your budget';

  // Default budget
  static const double defaultBudget = 0.0;

  // Tracking types
  static const String trackingMonthly = 'monthly';
  static const String trackingTotal = 'total';

  // Roles
  static const String roleOwner = 'owner';
  static const String roleEditor = 'editor';
  static const String roleViewer = 'viewer';

  // Invite status
  static const String invitePending = 'pending';
  static const String inviteAccepted = 'accepted';
  static const String inviteDeclined = 'declined';

  // Notification types
  static const String notifInvite = 'invite';
  static const String notifExpense = 'expense';
  static const String notifChat = 'chat';
  static const String notifGeneral = 'general';

  // SharedPreferences keys
  static const String prefDarkMode = 'dark_mode';

  // Pagination
  static const int pageSize = 20;
}
