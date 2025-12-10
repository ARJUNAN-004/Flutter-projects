import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "YOUR_CLOUD_NAME";     // change this
  static const String uploadPreset = "YOUR_UPLOAD_PRESET"; // change this

  static Future<String?> uploadImage(File image) async {
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/da7qor6kl/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = "foodapp"
      ..files.add(await http.MultipartFile.fromPath("file", image.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final exp = RegExp('"secure_url":"(.*?)"');
      final match = exp.firstMatch(resBody);
      return match?.group(1)?.replaceAll(r'\/', '/');
    }
    return null;
  }
}
