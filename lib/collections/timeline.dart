import 'dart:ffi';
import 'dart:typed_data';

import 'package:isar/isar.dart';

part 'timeline.g.dart';

@Collection()
class Timeline {
  Id id = Isar.autoIncrement;

  String? image;
  late String comment;
  late bool umai;
  late DateTime createdAt;
  late DateTime updatedAt;
  @Index()
  late int shopId;
  late DateTime date;
}
