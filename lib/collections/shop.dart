import 'dart:ffi';

import 'package:isar/isar.dart';

part 'shop.g.dart';

@Collection()
class Shop {
  Id id = Isar.autoIncrement;

  late String shopName;
  late String shopAddress;
  late String shopMapIconKind;
  late double shopLatitude;
  late double shopLongitude;
  late double shopStar;
  late DateTime createdAt;
  late DateTime updatedAt;
}
