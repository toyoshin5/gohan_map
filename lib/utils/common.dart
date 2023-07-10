import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

// 画像をbase64に変換する関数
Future<String> fileToBase64(File? file) async {
  if (file == null) {
    return "";
  }

  List<int> buffer = await file.readAsBytes();
  String base64File = base64Encode(buffer);
  return base64File;
}

// base64の画像ファイルをFileクラスに変換する関数
File? base64ImageToFile(String? base64Image) {
  if (base64Image == null) {
    return null;
  }

  Uint8List buffer = base64Decode(base64Image);
  return File.fromRawPath(buffer);
}
