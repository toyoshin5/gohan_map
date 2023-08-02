// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/model/hotpepper_shop.dart';
import 'package:gohan_map/utils/isar_utils.dart';

import '../component/app_search_bar.dart';

class PlaceSearchPage extends StatefulWidget {
  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  final LatLng mapCenter;
  const PlaceSearchPage({
    Key? key,
    required this.mapCenter,
  }) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchText = "";
  List<Shop> shopList = [];
  List<HotPepperShop>? hpShopList;

  bool isGettingHpLatlng = false;
  @override
  void initState() {
    super.initState();
    _searchShops("");
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      showKnob: false,
      initialChildSize: 0.6,
      child: Padding(
        //余白を作るためのウィジェット
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28), //左右に16pxの余白を作る
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //検索バー
            AppSearchBar(
              autofocus: true,
              onChanged: (text) {
                setState(() {
                  searchText = text;
                });
                _searchShops(text);
                _searchHPShop(text);
              },
              onSubmitted: (text) {
                setState(() {
                  searchText = text;
                });
                _searchShops(text);
                _searchHPShop(text);
              },
            ),
            const SizedBox(
              height: 32,
            ),
            //追加済みの飲食店
            if (shopList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '追加済みの飲食店',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            //追加済みの飲食店検索結果一覧
            for (var shop in shopList)
              Card(
                elevation: 0, //影を消す
                color: AppColors.backgroundWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), //角丸の大きさ
                ),
                child: ListTile(
                  title: Text(shop.shopName),
                  titleTextStyle: const TextStyle(fontSize: 18, color: AppColors.blackTextColor, overflow: TextOverflow.ellipsis),
                  subtitle: Text(shop.shopAddress),
                  subtitleTextStyle: const TextStyle(overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context, shop.id);
                  },
                ),
              ),
            if ((hpShopList?.isNotEmpty ?? true) && shopList.isNotEmpty && searchText.isNotEmpty) ...[
              const Divider(
                height: 32,
                color: Colors.black54,
              ),
            ],
            //新規飲食店
            if ((hpShopList?.isNotEmpty ?? true) && searchText.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  '新規飲食店を追加',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            //検索結果が多すぎる場合
            if (hpShopList == null && searchText.isNotEmpty)
              const Center(
                child: Text(
                  "検索中..",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            //新規飲食店検索結果一覧
            for (var hpShop in hpShopList ?? [])
              Card(
                //影付きの角丸四角形
                elevation: 0,
                color: AppColors.backgroundWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(hpShop.name),
                  titleTextStyle: const TextStyle(fontSize: 18, color: AppColors.blackTextColor, overflow: TextOverflow.ellipsis),
                  subtitle: Text(hpShop.address),
                  subtitleTextStyle: const TextStyle(overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context, hpShop);
                  },
                ),
              ),
            //クレジット
            if (hpShopList != null && hpShopList!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'images/hotpepper-s.gif',
                    )
                  ],
                ),
              ),
            //検索結果なし
            if (((hpShopList?.isEmpty) ?? false) && shopList.isEmpty)
              const Center(
                child: Text(
                  '検索結果がありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _searchShops(String text) {
    IsarUtils.searchShops(text).then(
      (value) {
        //更新日順に並び替え
        value.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        setState(() {
          shopList = value;
        });
      },
    );
  }

  http.Client client = http.Client(); // HTTPクライアントを格納する
  CancelableOperation? _cancelableOperation;

  //店名からHotPepperの店舗一覧を取得,検索バーに入力するたびに呼び出す
  Future<void> _searchHPShop(String name) async {
    //全角空白を半角空白に変換
    name = name.replaceAll(RegExp(r'　'), ' ');
    const String apiKey = String.fromEnvironment("HOTPEPPER_API_KEY");
    final String apiUrl = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=$apiKey&keyword=$name&format=json';
    try {
      _cancelableOperation?.cancel();
      _cancelableOperation = CancelableOperation.fromFuture(
        client.get(Uri.parse(apiUrl)),
      ).then((response) {
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['results']['shop'] != null) {
            List<HotPepperShop> shops = [];
            for (var shop in responseData['results']['shop']) {
              shops.add(HotPepperShop(hpID: shop['id'], name: shop['name'], address: shop['address'], latlng: LatLng(shop['lat'], shop['lng'])));
            }
            //距離順に並び替え
            shops = _sortByDist(shops, widget.mapCenter);
            setState(() {
              hpShopList = shops;
            });
          } else {
            setState(() {
              hpShopList = [];
            });
          }
        } else {
          setState(() {
            hpShopList = [];
          });
        }
      });
    } catch (e) {
      setState(() {
        hpShopList = [];
      });
    }
    setState(() {
      hpShopList = null;
    });
  }

  //HotPepperAPIから取得した店舗を距離順に並び替える関数
  List<HotPepperShop> _sortByDist(List<HotPepperShop> shops, LatLng point) {
    shops.sort((a, b) {
      double distA = _calculateDistance(a.latlng, point);
      double distB = _calculateDistance(b.latlng, point);
      return distA.compareTo(distB);
    });
    return shops;
  }

  //2点間の緯度経度の直線を計算する関数
  double _calculateDistance(LatLng a, LatLng b) {
    double earthRadius = 6371000; //m
    double latDiff = _degreesToRadians(b.latitude - a.latitude);
    double lonDiff = _degreesToRadians(b.longitude - a.longitude);

    double aLat = _degreesToRadians(a.latitude);
    double bLat = _degreesToRadians(b.latitude);

    double haversine = pow(sin(latDiff / 2), 2) + cos(aLat) * cos(bLat) * pow(sin(lonDiff / 2), 2);
    double distance = 2 * earthRadius * asin(sqrt(haversine));
    return distance;
  }

  //度数法から弧度法に変換
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }


}
