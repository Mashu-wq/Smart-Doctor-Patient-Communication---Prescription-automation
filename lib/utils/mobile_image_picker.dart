// // lib/helpers/mobile_image_picker.dart
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// Future<Map<String, dynamic>> pickImageMobile() async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//   if (pickedFile != null) {
//     return {'file': File(pickedFile.path)};
//   } else {
//     return {};
//   }
// }
