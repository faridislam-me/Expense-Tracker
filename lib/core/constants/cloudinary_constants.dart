class CloudinaryConstants {
  CloudinaryConstants._();

  // Replace with your Cloudinary cloud name
  static const String cloudName = 'YOUR_CLOUD_NAME';

  // Replace with your unsigned upload preset
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static const String receiptFolder = 'expense_tracker/receipts';
  static const String profileFolder = 'expense_tracker/profiles';
}
