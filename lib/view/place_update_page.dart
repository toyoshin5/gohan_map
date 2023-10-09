import 'dart:convert';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_haptic/haptic.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/component/app_rating_bar.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/utils/map_pins.dart';
import 'package:http/http.dart' as http;

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    defaultLatLng = LatLng(widget.shop.shopLatitude, widget.shop.shopLongitude);
    shopName = widget.shop.shopName;
    shopLatitude = widget.shop.shopLatitude;
    shopLongitude = widget.shop.shopLongitude;
    shopMapIconKind = widget.shop.shopMapIconKind;
  }

  MapController mapController = MapController();
  late LatLng defaultLatLng;

  late String shopName;
  late double shopLatitude;
  late double shopLongitude;
  late String shopMapIconKind;
  bool isValidating = false;

  @override
  Widget build(BuildContext context) {
    final String? pinImgPath = findPinByKind(shopMapIconKind)?.pinImagePath;

    return AppModal(
      initialChildSize: 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //飲食店名
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                      child: Text(
                    "飲食店編集",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(width: 24),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.pop(context); //前の画面に戻る
                      },
                    ),
                  ),
                ],
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _ShopNameTextField(
                initialValue: shopName,
                onChanged: (value) {
                  setState(() {
                    shopName = value;
                  });
                },
              ),
            ),
            //地図
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Text(
                "場所",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.backgroundGreyColor,
                      ),
                    ),
                    child: FutureBuilder(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final pref = snapshot.data as SharedPreferences;
                          final String currentTileURL =
                              pref.getString("currentTileURL") ??
            "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png";
                          return FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              center: defaultLatLng, //東京駅
                              zoom: 15.0,
                              maxZoom: 17.0,
                              minZoom: 3.0,
                              onPositionChanged: (position, hasGesture) {
                                if (position.center != null) {
                                  setState(() {
                                    shopLatitude = position.center!.latitude;
                                    shopLongitude = position.center!.longitude;
                                  });
                                }
                              },
                              onTap: (tapPosition, latlng) {
                                _animatedMapMove(latlng, 15, 500);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: currentTileURL,
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),

                  //上にimages/pin.pngを重ねる。ただしピンの下端がSizedBoxの中心になるようにする。
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 35,
                          width: 35,
                          child: Image.asset(pinImgPath ?? "images/pin.png"),
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                  //右下に戻すボタンを表示
                  if (defaultLatLng.latitude != shopLatitude ||
                      defaultLatLng.longitude != shopLongitude)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, right: 16),
                        child: SizedBox(
                          height: 44,
                          width: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: AppColors.blackTextColor,
                              backgroundColor: AppColors.backgroundWhiteColor,
                            ),
                            onPressed: () {
                              _animatedMapMove(defaultLatLng, 15, 500);
                            },
                            child: const Icon(
                              Icons.replay_outlined,
                              color: AppColors.blueTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
                  backgroundColor: AppColors.backgroundWhiteColor,
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
                              AppColors.blueTextColor),
                        ),
                      ),
                    const Text(
                      '決定',
                      style: TextStyle(
                          color: AppColors.blueTextColor,
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
                  backgroundColor: AppColors.backgroundWhiteColor,
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
    setState(() {
      isValidating = true;
    });
    //住所取得
    final shopAddress =
        await _getAddressFromLatLng(LatLng(shopLatitude, shopLongitude));
    //バリデーション
    if (context.mounted) {
      if (shopName.isEmpty) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('店名を入力してください'),
              content: const Text('店を登録するためには、店名の入力が必要です。'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        setState(() {
          isValidating = false;
        });
        return;
      } else if (shopAddress.isEmpty || shopAddress == "住所を取得できませんでした") {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('住所を取得できません'),
              content: const Text('インターネットへの接続状況をご確認ください。'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        setState(() {
          isValidating = false;
        });
        return;
      }
      _updateDB(shopAddress);
    }
  }

  Future<void> _updateDB(String shopAddress) async {
    final shop = Shop()
      ..id = widget.shop.id
      ..shopName = shopName
      ..shopAddress = shopAddress
      ..googleMapURL = null
      ..googlePlaceId = widget.shop.googlePlaceId
      ..shopLatitude = shopLatitude
      ..shopLongitude = shopLongitude
      ..shopMapIconKind = shopMapIconKind
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
      if (isDeleted){
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom, int millsec) {
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    final controller = AnimationController(
        duration: Duration(milliseconds: millsec), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  //緯度経度から住所を取得する
  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    const String apiKey = String.fromEnvironment("YAHOO_API_KEY");
    final String apiUrl =
        'https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=$apiKey&output=json';
    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final address = responseData['Feature'][0]['Property']['Address'];
        return address;
      } else {
        return '住所を取得できませんでした';
      }
    } catch (e) {
      return '住所を取得できませんでした';
    }
  }
}

class _ShopNameTextField extends StatelessWidget {
  const _ShopNameTextField({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);
  final Function(String) onChanged;
  final String? initialValue;
  @override
  Widget build(BuildContext context) {
    //角丸,白いぬりつぶし,枠線なし
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: '店名を入力',
        filled: true,
        fillColor: AppColors.textFieldColor,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.textFieldColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.textFieldColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
