import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/cloudinary_constants.dart';

class CloudinaryService {
  Future<String?> uploadImage(String filePath, {String? folder}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConstants.uploadUrl),
      );

      request.fields['upload_preset'] = CloudinaryConstants.uploadPreset;
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      }

      debugPrint(
        '[CLOUDINARY] Upload failed: ${response.statusCode} ${response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('[CLOUDINARY] uploadImage error: $e');
      return null;
    }
  }
}
