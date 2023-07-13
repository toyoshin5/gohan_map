import 'dart:convert';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/component/app_rating_bar.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:http/http.dart' as http;

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:latlong2/latlong.dart';

// 飲食店の更新画面
class PlaceUpdatePage extends StatefulWidget {
  final Shop shop;

  const PlaceUpdatePage({Key? key, required this.shop}) : super(key: key);

  @override
  State<PlaceUpdatePage> createState() => _PlaceUpdatePageState();
}

class _PlaceUpdatePageState extends State<PlaceUpdatePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    defaultLatLng = LatLng(widget.shop.shopLatitude, widget.shop.shopLongitude);
    shopName = widget.shop.shopName;
    shopLatitude = widget.shop.shopLatitude;
    shopLongitude = widget.shop.shopLongitude;
    shopStar = widget.shop.shopStar;
  }

  MapController mapController = MapController();
  late LatLng defaultLatLng;

  late String shopName;
  late double shopLatitude;
  late double shopLongitude;
  late double shopStar;

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.8,
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
                  FlutterMap(
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
                        urlTemplate: 'https://api.maptiler.com/maps/jp-mierune-streets/{z}/{x}/{y}@2x.png?key=j4Xnfvwl9nEzUVlzCdBr',
                      ),
                    ],
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
                          child: Image.asset("images/pin.png"),
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                  //右下に戻すボタンを表示
                  if (defaultLatLng.latitude != shopLatitude || defaultLatLng.longitude != shopLongitude)
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
            //評価
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Text(
                "評価",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AppRatingBar(
                onRatingUpdate: (value) {
                  setState(() {
                    shopStar = value;
                  });
                },
                initialRating: shopStar),
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
                onPressed: () {
                  _onTapComfirm(context);
                },
                child: const Text(
                  '決定',
                  style: TextStyle(color: AppColors.blueTextColor, fontWeight: FontWeight.bold),
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
                  Navigator.pop(context);
                },
                child: const Text(
                  'キャンセル',
                  style: TextStyle(color: AppColors.redTextColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//決定ボタンを押した時の処理
  Future<void> _onTapComfirm(BuildContext context) async {
    //住所取得
    final shopAddress = await _getAddressFromLatLng(LatLng(shopLatitude, shopLongitude));
    //バリデーション
    if(context.mounted){
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
      ..shopLatitude = shopLatitude
      ..shopLongitude = shopLongitude
      ..shopStar = shopStar
      ..createdAt = widget.shop.createdAt
      ..updatedAt = DateTime.now();
    await IsarUtils.createShop(shop);
    if (context.mounted) {
      Navigator.pop(context);
      return;
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom, int millsec) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    final controller = AnimationController(duration: Duration(milliseconds: millsec), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      mapController.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
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
    final String apiUrl = 'https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=$apiKey&output=json';
    try{
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final address = responseData['Feature'][0]['Property']['Address'];
      return address;
      } else {
        return '住所を取得できませんでした';
      }
    }catch(e){
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