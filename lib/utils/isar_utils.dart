import 'package:gohan_map/utils/common.dart';
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
    // timelineの削除(画像ファイルを削除するため、関数経由する)
    for (var element in (await getTimelinesByShopId(id))) {
      deleteTimeline(element.id);
    }
    await isar!.writeTxn(() async {
      await isar!.shops.delete(id);
    });
  }

  // timelineの取得
  static Future<List<Timeline>> getTimelinesByShopId(int shopId) async {
    await ensureInitialized();
    final timelines = await isar!.timelines
        .where()
        .shopIdEqualTo(shopId)
        .sortByDateDesc()
        .thenByCreatedAt()
        .findAll();
    return timelines.toList();
  }

  static Future<List<Timeline>> getAllTimelines() async {
    await ensureInitialized();
    final timelines = await isar!.timelines
        .where()
        .sortByDateDesc()
        .thenByCreatedAt()
        .findAll();
    return timelines.toList();
  }

  static Future<Timeline?> getTimelineById(int id) async {
    await ensureInitialized();
    final timeline = await isar!.timelines.where().idEqualTo(id).findFirst();
    return timeline;
  }

  // timelineの作成・更新
  static Future<void> createTimeline(Timeline timeline) async {
    await ensureInitialized();
    var beforeTimeline =
        await isar!.timelines.where().idEqualTo(timeline.id).findFirst();
    // 編集の場合、既存の画像ファイルを先に削除する
    if (beforeTimeline != null) {
      deleteImageFile(beforeTimeline.image);
    }
    await isar!.writeTxn(() async {
      await isar!.timelines.put(timeline);
    });
  }

  // timelineの削除
  static Future<void> deleteTimeline(Id id) async {
    ensureInitialized();
    var beforeTimeline =
        await isar!.timelines.where().idEqualTo(id).findFirst();
    // 画像ファイルを先に削除する
    if (beforeTimeline != null) {
      deleteImageFile(beforeTimeline.image);
    }
    await isar!.writeTxn(() async {
      await isar!.timelines.delete(id);
    });
  }

  // shopの取得
  static Future<Shop?> getShopById(Id id) async {
    await ensureInitialized();
    final shop = await isar!.shops.get(id);
    return shop;
  }

  //googlePlaceIdからshopを取得
  static Future<Shop?> getShopByGooglePlaceId(String googlePlaceId) async {
    await ensureInitialized();
    final shop = await isar!.shops
        .where()
        .filter()
        .googlePlaceIdEqualTo(googlePlaceId)
        .findFirst();
    return shop;
  }
  //   final shop = await isar!.writeTxn((isar) async {
  //     // 'googlePlaceId'が指定したテキストであるShopレコードを検索
  //     final shopQuery = isar.read<Shop>()
  //         .where()
  //         .filter()
  //         .googlePlaceIdEqualTo(googlePlaceId)
  //         .build();

  //     final shops = await shopQuery.find();

  //     if (shops.isNotEmpty) {
  //       // 該当するレコードが存在する場合、最初の要素を返す
  //       return shops.first;
  //     } else {
  //       // 該当するレコードが存在しない場合、nullを返す
  //       return null;
  //     }
  //   } as Future Function());

  //   return shop;
  // }
}
