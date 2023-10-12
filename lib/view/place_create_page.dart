
import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';

import 'package:gohan_map/collections/shop.dart';

import 'package:gohan_map/utils/map_pins.dart';
import 'package:gohan_map/utils/isar_utils.dart';
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
                  _onTapComfirm(context,false);
                },
                child: const Text(
                  '店舗を登録',
                  style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold),
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
                  _onTapComfirm(context,true);
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
  void _onTapComfirm(BuildContext context,bool wantToGoFlg) {
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
      if (wantToGoFlg){
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

  // //緯度経度から住所を取得する
  // Future<String> _getAddressFromLatLng(LatLng latLng) async {
  //   const String apiKey = String.fromEnvironment("YAHOO_API_KEY");
  //   final String apiUrl =
  //       'https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=$apiKey&output=json';
  //   final response = await http.get(Uri.parse(apiUrl));
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     final address = responseData['Feature'][0]['Property']['Address'];
  //     return address;
  //   } else {
  //     return '住所を取得できませんでした';
  //   }
  // }
}

// //店名を入力するWidget
// class _ShopNameTextField extends StatelessWidget {
//   final Function(String) onChanged;
//   final String? initialShopName;

//   const _ShopNameTextField({
//     Key? key,
//     required this.onChanged,
//     this.initialShopName,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     //角丸,白いぬりつぶし,枠線なし
//     return Flexible(
//       child: TextFormField(
//         decoration: InputDecoration(
//           hintText: '店名を入力',
//           filled: true,
//           fillColor: AppColors.whiteColor,
//           contentPadding: const EdgeInsets.all(16),
//           enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: AppColors.whiteColor,
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: AppColors.whiteColor,
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         initialValue: initialShopName,
//         onChanged: onChanged,
//       ),
//     );
//   }
// }
