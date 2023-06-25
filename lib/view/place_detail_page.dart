import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/view/place_post_page.dart';
import 'package:isar/isar.dart';

import '../utils/isar_utils.dart';

///飲食店の詳細画面
class PlaceDetailPage extends StatefulWidget {
  final Id id;
  const PlaceDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Shop? selectedShop;
  @override
  void initState() {
    super.initState();
    IsarUtils.getShopById(widget.id).then((shop) {
      setState(() {
        selectedShop = shop;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                if (selectedShop == null) {
                  return;
                }
                showModalBottomSheet(
                  //モーダルを表示する関数
                  barrierColor: Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true, //スクロールで閉じたりするか
                  builder: (context) {
                    return PlacePostPage(
                      shop: selectedShop!,
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
