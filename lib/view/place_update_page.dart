
import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/utils/map_pins.dart';

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

// 飲食店の更新画面
class PlaceUpdatePage extends StatefulWidget {
  final Shop shop;

  const PlaceUpdatePage({Key? key, required this.shop}) : super(key: key);

  @override
  State<PlaceUpdatePage> createState() => _PlaceUpdatePageState();
}

class _PlaceUpdatePageState extends State<PlaceUpdatePage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    shopMapIconKind = widget.shop.shopMapIconKind;
    wantToGoFlg = widget.shop.wantToGoFlg;
    Future(() async {
      // 一度でも行ったことがあるか
      haveEverBeen = await IsarUtils.getTimelinesByShopId(widget.shop.id)
          .then((value) => value.isNotEmpty);
      setState(() {
        // reload
      });
    });
  }

  MapController mapController = MapController();
  late String shopMapIconKind;
  late bool wantToGoFlg;
  bool isValidating = false;
  bool haveEverBeen = true;

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //飲食店名
            Text(
              widget.shop.shopName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            //住所
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: Colors.blue,
                  ),
                  Padding(padding: EdgeInsets.only(right: 5)),
                  Text(
                    '住所',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Text(
              widget.shop.shopAddress,
              style: const TextStyle(fontSize: 16),
            ),
            // ピンの種類
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                'ピンの種類',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButton(
              items: [
                for (var v in mapPins)
                  DropdownMenuItem(
                      value: v.kind,
                      child: Row(children: [
                        Container(
                          width: 30,
                          height: 40,
                          padding: const EdgeInsets.only(right: 10),
                          child: Image.asset(
                            v.pinImagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(v.displayName),
                      ]))
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  shopMapIconKind = value;
                });
              },
              value: shopMapIconKind,
            ),
            // 行きたいフラグ
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                '訪問状況',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Opacity(
              opacity: (haveEverBeen) ? 0.5 : 1,
              child: CupertinoSlidingSegmentedControl(
                groupValue: wantToGoFlg,
                children: const <bool, Widget>{
                  true: Text('行ってみたい'),
                  false: Text('行った'),
                },
                onValueChanged: (bool? value) {
                  if (value == null || haveEverBeen) return;
                  setState(() {
                    wantToGoFlg = value;
                  });
                },
              ),
            ),
            if(haveEverBeen)
            const Text("記録済みのため、行ってみたいへの変更はできません。", style: TextStyle(color: Colors.grey, fontSize: 12),),
            //決定ボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(top: 30, bottom: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.whiteColor,
                ),
                onPressed: (isValidating)
                    ? null
                    : () {
                        _onTapComfirm(context);
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //ロード中はインジケーターを表示
                    if (isValidating)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 14,
                        width: 14,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                    const Text(
                      '決定',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // キャンセルボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 50),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.whiteColor,
                ),
                onPressed: () {
                  _deleteShop();
                },
                child: const Text(
                  '削除',
                  style: TextStyle(
                      color: AppColors.redTextColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isDeleted = false;
//決定ボタンを押した時の処理
  Future<void> _onTapComfirm(BuildContext context) async {
    _updateDB();
  }

  Future<void> _updateDB() async {
    final shop = Shop()
      ..id = widget.shop.id
      ..shopName = widget.shop.shopName
      ..shopAddress = widget.shop.shopAddress
      ..googlePlaceId = widget.shop.googlePlaceId
      ..shopLatitude = widget.shop.shopLatitude
      ..shopLongitude = widget.shop.shopLongitude
      ..shopMapIconKind = shopMapIconKind
      ..wantToGoFlg = wantToGoFlg
      ..createdAt = widget.shop.createdAt
      ..updatedAt = DateTime.now();
    await IsarUtils.createShop(shop);
    if (context.mounted) {
      //振動
      Haptic.onSuccess();
      //最初に戻る
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    setState(() {
      isValidating = false;
    });
  }

  Future<void> _deleteShop() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
            title: const Text('店情報を削除しますか？'),
            message: const Text("店に関する全ての投稿も削除されます。"),
            actions: [
              CupertinoActionSheetAction(
                child: const Text(
                  '削除',
                  style: TextStyle(
                      color: AppColors.redTextColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await IsarUtils.deleteShop(widget.shop.id);
                  if (context.mounted) {
                    setState(() {
                      // reload
                    });
                    isDeleted = true;
                    Navigator.of(context, rootNavigator: true)
                        .pop(context); //rootNavigator: trueを指定しないと、モーダルが閉じない
                  }
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              onPressed: () {
                isDeleted = false;
                Navigator.of(context, rootNavigator: true).pop(context);
              },
            ));
      },
    ).then((value) {
      if (isDeleted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}
