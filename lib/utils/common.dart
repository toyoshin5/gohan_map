import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

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
Future<File?> base64ImageToFile(String? base64Image) async {
  if (base64Image == null || base64Image.isEmpty) {
    return null;
  }

  final path = await getLocalPath;
  final imagePath = '$path/temporary-image-base64-decode.png';
  File imageFile = File(imagePath);
  Uint8List buffer = base64Decode(base64Image);

  final localFile = await imageFile.writeAsBytes(buffer);
  return localFile;
}

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String?> saveImageFile(File? image) async {
  if (image == null) return null;

  final path = await getLocalPath();
  final name = Uuid().v1() + p.extension(image.path);
  final imagePath = "$path/$name";
  var imageFile = File(imagePath);
  await imageFile.writeAsBytes(await image.readAsBytes());

  return imagePath;
}

Future deleteImageFile(String? imagePath) async {
  if (imagePath == null) return;

  var file = File(imagePath);
  if (file.existsSync()) {
    file.delete();
  }
}
