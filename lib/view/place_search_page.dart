import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/utils/apis.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../component/app_search_bar.dart';

class PlaceSearchPage extends StatefulWidget {
  final MapController mapController;

  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  const PlaceSearchPage({Key? key, required this.mapController})
      : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchText = "";
  List<Shop> shopList = [];
  bool isLoadingPlaceApi = false;
  List<PlaceApiRestaurantResult> placeApiRestaurants = [];

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
              },
              onSubmitted: (text) {
                // APIを叩く回数を減らすため、決定時のみ発火する
                _searchRestaurantsByGoogleApi();
              },
            ),
            const SizedBox(
              height: 32,
            ),
            const Text("登録済み"),
            for (var shop in shopList)
              Card(
                //影付きの角丸四角形
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
            const SizedBox(
              height: 32,
            ),
            const Text("マップ付近の飲食店"),
            if (isLoadingPlaceApi)
              const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: CircularProgressIndicator(),
                  )),
            for (var shop in placeApiRestaurants)
              Card(
                //影付きの角丸四角形
                elevation: 0, //影を消す
                color: AppColors.backgroundWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), //角丸の大きさ
                ),
                child: ListTile(
                  title: Text(shop.name),
                  titleTextStyle: const TextStyle(
                      fontSize: 18,
                      color: AppColors.blackTextColor,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(shop.address),
                  subtitleTextStyle:
                      const TextStyle(overflow: TextOverflow.ellipsis),
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

  void _searchRestaurantsByGoogleApi() async {
    setState(() {
      isLoadingPlaceApi = true;
      placeApiRestaurants = [];
    });

    var restaurantsResult = await searchRestaurantsByGoogleMapApi(
      searchText,
      LatLng(widget.mapController.center.latitude,
          widget.mapController.center.longitude),
    );
    print("API呼び出し"); // TODO: ロギングツールの導入を検討
    setState(() {
      isLoadingPlaceApi = false;
      placeApiRestaurants = restaurantsResult;
    });
  }
}
