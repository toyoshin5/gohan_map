import 'dart:math';
import 'dart:ui';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_map.dart';
import 'package:gohan_map/component/app_search_bar.dart';
import 'package:gohan_map/utils/apis.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/utils/mapPins.dart';
import 'package:gohan_map/utils/safearea_utils.dart';
import 'package:gohan_map/view/place_create_page.dart';
import 'package:gohan_map/view/place_detail_page.dart';
import 'package:gohan_map/view/place_search_page.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';

///地図が表示されている画面
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  // Key? keyは、ウィジェットの識別子。ウィジェットの状態を保持するためには必要だが、今回は特に使わない。
  List<Marker> pins = [];
  Map<Id, bool> tapFlgs = {};
  List<Shop> shops = [];
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _loadAllShop(); //DBから飲食店の情報を取得してピンを配置

      await Future.delayed(
          const Duration(milliseconds: 500)); // 高速に画面が切り替わることを避ける
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          child: AppMap(
            pins: pins,
            mapController: mapController,
            onLongPress: (_, latLng) {
              //画面の座標, 緯度経度
              //振動
              HapticFeedback.mediumImpact();

              setState(() {
                //ピンを配置する
                _addPinToMap(latLng, null);
              });
              //mapをスクロールする
              final deviceHeight = MediaQuery.of(context).size.height;
              _moveToPin(latLng, deviceHeight * 0.2);
              showModalBottomSheet(
                barrierColor: Colors.black.withOpacity(0),
                isDismissible: true,
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return PlaceCreatePage(
                    latlng: latLng,
                  );
                },
              ).then((value) {
                _loadAllShop();
              });
            },
          ),
        ),
        //下の検索ボタン
        // Center(
        //   //画像ボタン
        //   child: Stack(
        //     children: [
        //       Image.asset(
        //         'images/pin_tap.png',
        //         width: 100,
        //         height: 100,
        //       ),
        //       Positioned.fill(
        //         child: Material(
        //           color: Colors.transparent,
        //           child: InkWell(
        //             onTap: () {
        //               // ボタンがタップされたときの処理
        //               print('Button tapped!');
        //             },
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        buildDummySearchWidget(),
      ],
    );
  }

  //下の検索バー
  Widget buildDummySearchWidget() {
    final paddingBottom = (SafeAreaUtil.unSafeAreaBottomHeight == 0)
        ? 24.0
        : SafeAreaUtil.unSafeAreaBottomHeight + 4.0;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          child: AbsorbPointer(
            child: ClipRRect(
              //ぼかす領域を指定するためのウィジェット
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BackdropFilter(
                //ぼかすためのウィジェット
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  //モーダル風UIの中身
                  decoration: BoxDecoration(
                    color: AppColors.backgroundModalColor,
                    border: Border.all(
                      color: AppColors.backgroundGrayColor,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 28, 16, paddingBottom),
                    child: AppSearchBar(
                      onSubmitted: (value) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            //検索バーをタップしたときの処理
            showModalBottomSheet(
              barrierColor: Colors.black.withOpacity(0),
              context: context,
              isDismissible: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return PlaceSearchPage(
                  mapController: mapController,
                ); //飲食店を検索する画面
              },
            ).then(
              (value) {
                //valueの型がInt→詳細画面
                //int型ならそのまま、Id型ならばnullにしたい
                int? id = (value is int) ? value : null;
                //valueの型がHotPepper→検索から新規作成
                PlaceApiRestaurantResult? paResult =
                    (value is PlaceApiRestaurantResult) ? value : null;

                //検索画面で追加済みの店を選択した場合、選択した場所の詳細画面を表示する。
                if (id != null) {
                  setState(() {
                    tapFlgs[id] = true;
                  });
                  showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0),
                    context: context,
                    isDismissible: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return PlaceDetailPage(
                        id: id,
                      ); //飲食店の詳細画面
                    },
                  ).then((value) => _onModalPop(value, id));
                  //ピンの緯度経度を取得
                  IsarUtils.getShopById(id).then((shop) {
                    if (shop != null) {
                      final latLng =
                          LatLng(shop.shopLatitude, shop.shopLongitude);
                      //ピンの位置に移動する
                      final deviceHeight = MediaQuery.of(context).size.height;
                      _moveToPin(latLng, deviceHeight * 0.2);
                    }
                  });
                }

                //検索画面で新規店舗を選択した場合、新規作成画面を表示する。
                if (paResult != null) {
                  setState(() {
                    //ピンを配置する
                    _addPinToMap(paResult.latlng, null);
                  });
                  //mapをスクロールする
                  final deviceHeight = MediaQuery.of(context).size.height;
                  _moveToPin(paResult.latlng, deviceHeight * 0.2);
                  showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0),
                    isDismissible: true,
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return PlaceCreatePage(
                        latlng: paResult.latlng,
                        initialShopName: paResult.name,
                      );
                    },
                  ).then((value) {
                    _loadAllShop();
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  //1つのピンを、地図に描画するための配列pinsに追加する関数
  void _addPinToMap(LatLng latLng, Shop? shop) {
    const markerSize = 40.0;
    const imgRatio = 345 / 512;
    final shopMapPin = findPinByKind(shop?.shopMapIconKind);

    pins.add(
      Marker(
        width: markerSize * imgRatio,
        height: markerSize,
        anchorPos: AnchorPos.align(AnchorAlign.top),
        point: latLng,
        builder: (context) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.diagonal3Values(
                tapFlgs[shop?.id] == true ? 1.3 : 1,
                tapFlgs[shop?.id] == true ? 1.3 : 1,
                1),
            transformAlignment: Alignment.bottomCenter,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  //ピンをタップしたときの処理
                  if (shop != null) {
                    setState(() {
                      tapFlgs[shop.id] = true;
                    });
                    final deviceHeight = MediaQuery.of(context).size.height;
                    _moveToPin(latLng, deviceHeight * 0.1);
                    showModalBottomSheet(
                      barrierColor: Colors.black.withOpacity(0),
                      isDismissible: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return PlaceDetailPage(
                          id: shop.id,
                        ); //飲食店の詳細画面
                      },
                    ).then((value) => _onModalPop(value, shop.id));
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(shopMapPin != null
                        ? shopMapPin.pinImagePath
                        : 'images/pins/pin_default.png'),
                    if (shop != null && shopMapPin != null)
                      Positioned(
                        left: 35,
                        top: 7,
                        child: Text(
                          shop.shopName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: shopMapPin.textColor),
                        ),
                      )
                  ],
                )),
          );
        },
      ),
    );
  }

  //DBから飲食店の情報を全て取得してピンを配置する関数
  Future<void> _loadAllShop() async {
    shops = await IsarUtils.getAllShops();
    pins = [];
    tapFlgs = {};
    for (var shop in shops) {
      tapFlgs.addAll({shop.id: false});
      _addPinToMap(LatLng(shop.shopLatitude, shop.shopLongitude), shop);
    }
    setState(() {
      // reload
    });
  }

  //modalから戻ってきたときに実行される関数
  void _onModalPop(dynamic value, int id) {
    //ピンの位置に移動する
    IsarUtils.getShopById(id).then((shop) {
      if (shop != null) {
        final latLng = LatLng(shop.shopLatitude, shop.shopLongitude);

        final deviceHeight = MediaQuery.of(context).size.height;
        _moveToPin(latLng, deviceHeight * 0.1);
      }
    });
    setState(() {
      tapFlgs[id] = false;
      _loadAllShop();
    });
  }

  //ピンの位置に移動する。offsetはピンを画面の中央から何dp上にずらして表示するか
  void _moveToPin(LatLng pinLocation, double offset) {
    var zoom = mapController.zoom;
    var rot = mapController.rotation;
    //1ピクセルあたりの緯度経度
    var pixelPerLat = pow(2, zoom + 8) / 360;
    var pixelPerLng =
        pow(2, zoom + 8) / 360 * cos(pinLocation.latitude * pi / 180);
    //ピンの位置から下へ移動する
    var lat =
        pinLocation.latitude - (offset / pixelPerLat * cos(rot * pi / 180));
    var lng =
        pinLocation.longitude + (offset / pixelPerLng * sin(rot * pi / 180));
    _animatedMapMove(LatLng(lat, lng), zoom);
  }

  //flutter_mapにはアニメーションありのmoveメソッドがないため、AnimationControllerで作成
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
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
}
