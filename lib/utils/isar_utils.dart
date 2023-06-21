import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../collections/shop.dart';
import '../collections/timeline.dart';

Future<Isar> initializeIsar() async {
  WidgetsFlutterBinding.ensureInitialized();

  var path = '';
  if (!kIsWeb) {
    final dir = await getApplicationSupportDirectory();
    path = dir.path;
  }

  final isar = await Isar.open(
    [
      ShopSchema,
      TimelineSchema,
    ],
    directory: path,
  );
  return isar;
}

// shopの全取得
Future<List<Shop>> getAllShops() async {
  final isar = await initializeIsar();
  final shops = await isar.shops.where().findAll();
  return shops.toList();
}

// shopの作成
Future<void> createShop(Shop shop) async {
  final isar = await initializeIsar();
  await isar.writeTxn(() async {
    await isar.shops.put(shop);
  });
}

// shopの削除
Future<void> deleteShop(Id id) async {
  final isar = await initializeIsar();
  await isar.writeTxn(() async {
    await isar.shops.delete(id);
  });
  // timelineの削除
  isar.timelines.where().shopIdEqualTo(id).deleteAll();
}

// timelineの取得
Future<List<Timeline>> getTimelinesByShopId(int shopId) async {
  final isar = await initializeIsar();
  final timelines =
      await isar.timelines.where().shopIdEqualTo(shopId).findAll();
  return timelines.toList();
}

// timelineの作成
Future<void> createTimeline(Timeline timeline) async {
  final isar = await initializeIsar();
  await isar.writeTxn(() async {
    await isar.timelines.put(timeline);
  });
}

// timelineの削除
Future<void> deleteTimeline(Id id) async {
  final isar = await initializeIsar();
  await isar.writeTxn(() async {
    await isar.timelines.delete(id);
  });
}
