import 'dart:async';
import 'dart:convert';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/model/overpass_shop.dart';
import 'package:gohan_map/utils/isar_utils.dart';

import '../component/app_search_bar.dart';

import 'package:http/http.dart' as http;

class PlaceSearchPage extends StatefulWidget {
  final MapController mapController;

  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  const PlaceSearchPage({
    Key? key,
    required this.mapController,
  }) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchText = "";
  List<Shop> shopList = [];
  List<OverPassShop>? overpassShopList;
  Timer? _debounce;
  http.Client client = http.Client(); // HTTPクライアントを格納する

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
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 28), //左右に16pxの余白を作る
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
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _getOverPassShopListFromName(text).then((list) {
                    setState(() {
                      overpassShopList = list;
                    });
                  });
                });
              },
              onSubmitted: (text) {
                setState(() {
                  searchText = text;
                });
                _searchShops(text);
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _getOverPassShopListFromName(text).then((list) {
                    setState(() {
                      overpassShopList = list;
                    });
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
                  titleTextStyle: const TextStyle(
                      fontSize: 18,
                      color: AppColors.blackTextColor,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(shop.shopAddress),
                  subtitleTextStyle:
                      const TextStyle(overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context, shop.id);
                  },
                ),
              ),

            //新規飲食店
            const Divider(
              height: 32,
              color: Colors.black54,
            ),
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
            //新規飲食店検索結果一覧
            for (OverPassShop overpassShop in overpassShopList ?? [])
              Card(
                //影付きの角丸四角形
                elevation: 0,
                color: AppColors.backgroundWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(overpassShop.name),
                  subtitle: overpassShop.address != null
                      ? Text(overpassShop.address!)
                      : null,
                  titleTextStyle: const TextStyle(
                      fontSize: 18,
                      color: AppColors.blackTextColor,
                      overflow: TextOverflow.ellipsis),
                  subtitleTextStyle:
                      const TextStyle(overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context, overpassShop);
                  },
                ),
              ),
            //検索結果なし
            if (((overpassShopList?.isEmpty) ?? false) && shopList.isEmpty)
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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

  //店名からHotPepperの店舗一覧を取得,検索バーに入力するたびに呼び出す
  Future<List<OverPassShop>?> _getOverPassShopListFromName(String name) async {
    //全角空白を半角空白に変換
    name = name.replaceAll(RegExp(r'　'), ' ');
    if (name.replaceAll(RegExp(r'\s'), '') == "") return [];

    final westLon = widget.mapController.bounds!.west;
    final eastLon = widget.mapController.bounds!.east;
    final northLat = widget.mapController.bounds!.north;
    final southLat = widget.mapController.bounds!.south;

    final String apiUrl =
        'https://lz4.overpass-api.de/api/interpreter?data=[out:json];node(${southLat},${westLon},${northLat},${eastLon})["amenity"~"fast_food|cafe|restaurant"]["name"~"${name}"];out;';
    try {
      print(apiUrl);
      final response = await client.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData != null) {
          final List<OverPassShop> shops = [];
          for (var shop in responseData["elements"]) {
            final overpassResponseShop = OverPassShop.fromJson(shop);
            shops.add(overpassResponseShop);
          }
          return shops;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}
