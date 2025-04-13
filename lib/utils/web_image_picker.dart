// // lib/helpers/web_image_picker.dart
// import 'dart:typed_data';
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;
// import 'dart:async';

// Future<Map<String, dynamic>> pickImageWeb() async {
//   final completer = Completer<Map<String, dynamic>>();
//   final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
//   uploadInput.click();

//   uploadInput.onChange.listen((event) {
//     final file = uploadInput.files?.first;
//     if (file == null) return;

//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);

//     reader.onLoadEnd.listen((e) {
//       final result = reader.result as Uint8List;
//       completer.complete({'bytes': result});
//     });
//   });

//   return completer.future;
// }
