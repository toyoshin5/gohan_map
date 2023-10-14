import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';

import 'package:gohan_map/collections/shop.dart';

import 'package:gohan_map/utils/map_pins.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

//飲食店の登録画面
class PlaceCreatePage extends StatefulWidget {
  final LatLng latlng;
  final String? initialShopName;
  final String placeId;
  final String address;
  const PlaceCreatePage(
      {Key? key,
      required this.latlng,
      this.initialShopName,
      required this.placeId,
      required this.address})
      : super(key: key);

  @override
  State<PlaceCreatePage> createState() => _PlaceCreatePageState();
}

class _PlaceCreatePageState extends State<PlaceCreatePage> {
  String shopMapIconKind = "default";
  File? image;
  double star = 4.0;
  DateTime date = DateTime.now();
  String comment = '';
  bool avoidkeyBoard = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.7,
      avoidKeyboardFlg: avoidkeyBoard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    color: AppColors.whiteColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.initialShopName ?? '名称未設定',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -12,
                  left: 16,
                  child: NewBudge(),
                ),
              ],
            ),
            //飲食店名
            Text(
              widget.initialShopName ?? '名称未設定',
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
              widget.address,
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
            //登録ボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(top: 12),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: () {
                  _onTapComfirm(context, false);
                },
                child: const Text(
                  '店舗を登録',
                  style: TextStyle(
                      color: AppColors.whiteColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            //行きたいボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(top: 12),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.whiteColor,
                ),
                onPressed: () {
                  _onTapComfirm(context, true);
                },
                child: const Text(
                  '行ってみたい店舗として登録',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold),
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
                  Navigator.pop(context);
                },
                child: const Text(
                  'キャンセル',
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

  //決定ボタンを押した時の処理
  void _onTapComfirm(BuildContext context, bool wantToGoFlg) {
    _addToDB(wantToGoFlg);
  }

  //DBに店を登録
  Future<void> _addToDB(bool wantToGoFlg) async {
    final shop = Shop()
      ..shopName = widget.initialShopName ?? '名称未設定'
      ..shopAddress = widget.address
      ..googleMapURL = null
      ..googlePlaceId = widget.placeId
      ..shopLatitude = widget.latlng.latitude
      ..shopLongitude = widget.latlng.longitude
      ..shopMapIconKind = shopMapIconKind
      ..wantToGoFlg = wantToGoFlg
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    IsarUtils.createShop(shop).then((shopId) {
      if (wantToGoFlg) {
        Navigator.pop(context);
        return;
      }
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('食事の記録を行いますか?'),
            content: const Text('早速このお店での食事の記録を残すことができます'),
            actions: [
              CupertinoDialogAction(
                child: const Text('後で行う'),
                onPressed: () async {
                  Navigator.pop(context, false);
                },
              ),
              CupertinoDialogAction(
                child: const Text(
                  '記録する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        },
      ).then((isInitialPost) {
        if (isInitialPost) {
          Navigator.pop(context, shopId);
        } else {
          Navigator.pop(context);
        }
      });
    });
  }
}

class NewBudge extends StatelessWidget {
  const NewBudge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.whiteColor,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greyColor,
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
        color: AppColors.primaryColor,
      ),
      child: const Center(
        child: Text(
          "NEW!!",
          style: TextStyle(
              height: 1.2,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }
}
