import 'dart:io';
import 'dart:convert';

//画像をbase64に変換する関数
Future<String> fileToBase64(File? file) async {
  if (file == null) {
    return "";
  }

  List<int> buffer = await file.readAsBytes();
  String base64File = base64Encode(buffer);
  return base64File;
}
