import 'package:isar/isar.dart';

part 'search_history.g.dart';

@Collection()
class SearchHistory {
  Id id = Isar.autoIncrement;
  late String name;
  late String placeId;
  late String address;
  late double shopLatitude;
  late double shopLongitude;
  late DateTime createdAt;
  late DateTime updatedAt;
}
