class CloudinaryConstants {
  CloudinaryConstants._();

  // Replace with your Cloudinary cloud name
  static const String cloudName = 'defisxnj1';

  static const String uploadPreset = 'expense_tracker';

  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static const String receiptFolder = 'expense_tracker/receipts';
  static const String profileFolder = 'expense_tracker/profiles';
}
