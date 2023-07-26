import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/model/hotpepper_shop.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';

import '../component/app_search_bar.dart';

import 'package:http/http.dart' as http;

class PlaceSearchPage extends StatefulWidget {
  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  const PlaceSearchPage({Key? key}) : super(key: key);

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
                _getHpShopListFromName(text).then((list) {
                  setState(() {
                    hpShopList = list;
                  });
                });
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
            if ((hpShopList?.isNotEmpty??true) && shopList.isNotEmpty&&searchText.isNotEmpty) ...[
              const Divider(
                height: 32,
                color: Colors.black54,
              ),
            ],
            //新規飲食店
            if ((hpShopList?.isNotEmpty??true) &&searchText.isNotEmpty) ...[
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
            if (hpShopList==null&&searchText.isNotEmpty)
              const Center(
                child: Text(
                  '検索結果が多すぎます',
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
                  onTap: () => _getLatlngFromHpId(hpShop.hpID).then((latlng) {
                    if (latlng != null) {
                      hpShop.latlng = latlng;
                      Navigator.pop(context, hpShop);
                    } else {
                      //Cupertinoアラートを表示
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('エラー'),
                            content: const Text('飲食店の詳細情報を取得できませんでした。'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }),
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
            if (((hpShopList?.isEmpty)??false) && shopList.isEmpty)
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

  //店名からHotPepperの店舗一覧を取得,検索バーに入力するたびに呼び出す
  Future<List<HotPepperShop>?> _getHpShopListFromName(String name) async {
    //全角空白を半角空白に変換
    name = name.replaceAll(RegExp(r'　'), ' ');
    const String apiKey = String.fromEnvironment("HOTPEPPER_API_KEY");
    final String apiUrl = 'http://webservice.recruit.co.jp/hotpepper/shop/v1?key=$apiKey&keyword=$name&format=json';
    try {
      final response = await client.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['results']['shop'] != null) {
          final List<HotPepperShop> shops = [];
          for (var shop in responseData['results']['shop']) {
            shops.add(HotPepperShop(hpID: shop['id'], name: shop['name'], address: shop['address']));
          }
          return shops;
        } else {
          final String errorMsg = responseData['results']['error'][0]['message'];
          if (errorMsg == "条件を絞り込んでください。") {
            return null; //検索結果が多すぎ
          }
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  //HotPepperのIdから緯度経度を取得,項目タップ時に呼び出す
  Future<LatLng?> _getLatlngFromHpId(String id) async {
    const String apiKey = String.fromEnvironment("HOTPEPPER_API_KEY");
    final String apiUrl = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=$apiKey&id=$id&format=json';
    try {
      final response = await client.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final double? lat = responseData['results']['shop'][0]['lat'];
        final double? lng = responseData['results']['shop'][0]['lng'];
        if (lat != null && lng != null) {
          final LatLng latlng = LatLng(lat, lng);
          return latlng;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
