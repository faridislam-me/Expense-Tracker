import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/cloudinary_constants.dart';
import '../../data/services/cloudinary_service.dart';

class ImageUploadProvider extends ChangeNotifier {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  String? _receiptUrl;
  String? _localPath;
  bool _isUploading = false;

  String? get receiptUrl => _receiptUrl;
  String? get localPath => _localPath;
  bool get isUploading => _isUploading;

  Future<void> pickAndUploadImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (file == null) return;

      _localPath = file.path;
      _isUploading = true;
      notifyListeners();

      final url = await _cloudinaryService.uploadImage(
        file.path,
        folder: CloudinaryConstants.receiptFolder,
      );

      _receiptUrl = url;
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      notifyListeners();
      debugPrint('[IMAGE_UPLOAD] pickAndUploadImage error: $e');
    }
  }

  void reset() {
    _receiptUrl = null;
    _localPath = null;
    _isUploading = false;
    notifyListeners();
  }
}
