import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/view/place_post_page.dart';
import 'package:gohan_map/view/place_update_page.dart';

///飲食店の詳細画面
class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: ダミーの店情報を削除する
    final Shop dummyShop = Shop()
      ..id = 1
      ..shopAddress = "北海道札幌市豊平区平岸２条１５丁目４−２３"
      ..shopLatitude = 43.024318
      ..shopLongitude = 141.366267
      ..shopName = "トリトン"
      ..shopStar = 3
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    // TODO: ダミーのタイムライン情報を削除する
    final Timeline dummyTimeline = Timeline()
      ..id = 1
      ..shopId = 1
      ..umai = true
      ..comment = "これはテスト投稿です！"
      ..date = new DateTime.now()
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return AppModal(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceDetailPage'),
            CupertinoButton(
              child: const Text('Post'),
              onPressed: () {
                showModalBottomSheet(
                  //モーダルを表示する関数
                  barrierColor: Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true, //スクロールで閉じたりするか
                  builder: (context) {
                    return PlacePostPage(
                      shop: dummyShop,
                    ); //ご飯投稿
                  },
                );
              },
            ),
            CupertinoButton(
              child: const Text('Edit'),
              onPressed: () {
                showModalBottomSheet(
                  //モーダルを表示する関数
                  barrierColor: Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true, //スクロールで閉じたりするか
                  builder: (context) {
                    return PlacePostPage(
                      shop: dummyShop,
                      timeline: dummyTimeline,
                    ); //ご飯投稿
                  },
                );
              },
            ),
             CupertinoButton(
              child: const Text('EditShop'),
              onPressed: () {
                showModalBottomSheet(
                  //モーダルを表示する関数
                  barrierColor: Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true, //スクロールで閉じたりするか
                  builder: (context) {
                    return PlaceUpdatePage(
                      shop: dummyShop,
                    ); //ご飯投稿
                  },
                );
              },
            ),
            CupertinoButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context); //前の画面に戻る
              },
            ),
            CupertinoButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context); //前の画面に戻る
              },
            ),
          ],
        ),
      ),
    );
  }
}
