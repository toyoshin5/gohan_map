import 'package:kana_kit/kana_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import '../collections/shop.dart';
import '../collections/timeline.dart';

class IsarUtils {
  static Isar? isar;
  static bool get isInitialized => isar != null; //isarが初期化されているか
  IsarUtils._() {
    throw AssertionError("private Constructor");
  } //コンストラクタを隠蔽

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    var path = '';
    if (!kIsWeb) {
      final dir = await getApplicationSupportDirectory();
      path = dir.path;
    }

    final isr = await Isar.open(
      [
        ShopSchema,
        TimelineSchema,
      ],
      directory: path,
    );
    isar = isr;
  }

  static Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await initialize();
    }
  }

  // shopの全取得
  static Future<List<Shop>> getAllShops() async {
    await ensureInitialized();
    final shops = await isar!.shops.where().findAll();
    return shops.toList();
  }

  // shopを条件で絞り込み検索
  static Future<List<Shop>> searchShops(String text) async {
    //テキストをローマ字に変換
    final kanaKit = KanaKit();
    final romaji = kanaKit.toRomaji(text);
    print(romaji);
    await ensureInitialized();
    final shops = await isar!.shops.filter().shopNameContains(text).findAll();
    return shops.toList();
  }

  // shopの作成
  static Future<Id> createShop(Shop shop) async {
    await ensureInitialized();
    await isar!.writeTxn(() async {
      await isar!.shops.put(shop);
    });
    //idを取得
    return shop.id;
  }

  // shopの削除
  static Future<void> deleteShop(Id id) async {
    await ensureInitialized();
    await isar!.writeTxn(() async {
      await isar!.shops.delete(id);
    });
    // timelineの削除
    isar!.timelines.where().shopIdEqualTo(id).deleteAll();
  }

  // timelineの取得
  static Future<List<Timeline>> getTimelinesByShopId(int shopId) async {
    await ensureInitialized();
    final timelines = await isar!.timelines.where().shopIdEqualTo(shopId).findAll();
    return timelines.toList();
  }

  // timelineの作成・更新
  static Future<void> createTimeline(Timeline timeline) async {
    await ensureInitialized();
    await isar!.writeTxn(() async {
      await isar!.timelines.put(timeline);
    });
  }

  // timelineの削除
  static Future<void> deleteTimeline(Id id) async {
    ensureInitialized();
    await isar!.writeTxn(() async {
      await isar!.timelines.delete(id);
    });
  }

  static Future<Shop?> getShopById(Id id) async {
    await ensureInitialized();
    final shop = await isar!.shops.get(id);
    return shop;
  }
}
