import 'dart:math';
import 'dart:ui';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_map.dart';
import 'package:gohan_map/component/app_search_bar.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/view/place_create_page.dart';
import 'package:gohan_map/view/place_detail_page.dart';
import 'package:gohan_map/view/place_search_page.dart';
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
  List<Shop> shops = [];
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadAllShop(); //DBから飲食店の情報を取得してピンを配置
  }

  @override
  Widget build(BuildContext context) {
    // buildメソッドは、ウィジェットを構築するメソッド。画面が表示されるときに呼ばれる。
    return Stack(
      children: [
        Material(
          child: AppMap(
            pins: pins,
            mapController: mapController,
            onLongPress: (_, latLng) {
              //画面の座標, 緯度経度
              setState(() {
                //ピンを配置する
                pins.add(
                  Marker(
                    width: 80,
                    height: 80,
                    point: latLng,
                    builder: (context) {
                      //pin.png
                      return Image.asset(
                        'images/pin.png',
                        width: 80,
                        height: 80,
                      );
                    },
                  ),
                );
              });
              //mapをスクロールする
              _moveToPin(latLng, 180);
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
                loadAllShop();
              });
            },
          ),
        ),
        Center(
          child: Column(
            //縦に並べる
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('MapPage'),
              CupertinoButton(
                //iOS風のボタン
                child: const Text('Detail'),
                onPressed: () {
                  showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0),
                    isDismissible: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    //isScrollControlled: true,
                    builder: (context) {
                      return const PlaceDetailPage(); //飲食店の詳細画面
                    },
                  );
                },
              ),
            ],
          ),
        ),
        //下の検索ボタン
        const _DummySearchWidget(),
      ],
    );
  }

  void loadAllShop() {
    IsarUtils.getAllShops().then(
      (value) => setState(() {
        shops = value;
        pins = [];
        for (var shop in shops) {
          pins.add(
            Marker(
              width: 80,
              height: 80,
              point: LatLng(shop.shopLatitude, shop.shopLongitude),
              builder: (context) {
                return Image.asset(
                  'images/pin.png',
                  width: 80,
                  height: 80,
                );
              },
            ),
          );
        }
      }),
    );
  }

  //ピンの位置に移動する。offsetはピンを画面の中央から何dp上にずらして表示するか
  void _moveToPin(LatLng pinLocation, double offset) {
    var zoom = mapController.zoom;
    var rot = mapController.rotation;
    //1ピクセルあたりの緯度経度
    var pixelPerLat = pow(2, zoom + 8) / 360;
    var pixelPerLng = pow(2, zoom + 8) / 360 * cos(pinLocation.latitude * pi / 180);
    //ピンの位置から下へ移動する
    var lat = pinLocation.latitude - (offset / pixelPerLat * cos(rot * pi / 180));
    var lng = pinLocation.longitude + (offset / pixelPerLng * sin(rot * pi / 180));
    _animatedMapMove(LatLng(lat, lng), zoom);
  }

  //flutter_mapにはアニメーションありのmoveメソッドがないため、AnimationControllerで作成
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
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
}

class _DummySearchWidget extends StatelessWidget {
  const _DummySearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
                    child: AppSearchBar(
                      onSubmitted: (value) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              barrierColor: Colors.black.withOpacity(0),
              context: context,
              isDismissible: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return const PlaceSearchPage(); //飲食店を検索する画面
              },
            ).then(
              (value) {
                //検索画面で場所を選択した場合、選択した場所の詳細画面を表示する。
                if (value != null) {
                  showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0),
                    context: context,
                    isDismissible: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return const PlaceDetailPage(); //飲食店の詳細画面
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
