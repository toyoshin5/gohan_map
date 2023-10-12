import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/utils/apis.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/utils/logger.dart';
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

class _PlaceSearchPageState extends State<PlaceSearchPage>
    with TickerProviderStateMixin {
  String searchText = "";
  List<Shop> shopList = [];
  bool isLoadingPlaceApi = false;
  List<PlaceApiRestaurantResult> placeApiRestaurants = [];
  late TabController tabController;
  int segmentIndex = 1; // 0: マップ付近の飲食店, 1: 登録済み

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    // TabBarViewは要素の高さが固定出なければいけないので、使用しない
    tabController.addListener(() {
      setState(() {
        // render
      });
    });
    _searchShops("");
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      showKnob: false,
      initialChildSize: 0.9,
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
              height: 24,
            ),

            Center(
              child: CupertinoSlidingSegmentedControl(
                groupValue: segmentIndex,
                children: const <int, Widget>{
                  0: Text("マップ付近の店舗を登録"),
                  1: Text("登録済み"),
                },
                onValueChanged: (value) {
                  setState(() {
                    segmentIndex = value as int;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 24,
            ),

            // マップ付近の飲食店
            if (segmentIndex == 0)
              NewRestaurantsTabPage(
                  restaurantList: placeApiRestaurants,
                  isLoading: isLoadingPlaceApi),
            // 登録済み
            if (segmentIndex == 1) RegisteredTabPage(shopList: shopList)
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
    if (searchText == "") return; // 空文字ではリクエストを送らない

    setState(() {
      isLoadingPlaceApi = true;
      placeApiRestaurants = [];
    });

    var restaurantsResult = await searchRestaurantsByGoogleMapApi(
      searchText,
      LatLng(widget.mapController.center.latitude,
          widget.mapController.center.longitude),
    );

    logger.d("API呼び出し");
    setState(() {
      isLoadingPlaceApi = false;
      placeApiRestaurants = restaurantsResult;
    });
  }
}

class NewRestaurantsTabPage extends StatelessWidget {
  final List<PlaceApiRestaurantResult> restaurantList;
  final bool isLoading;

  const NewRestaurantsTabPage(
      {Key? key, required this.restaurantList, required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading)
          const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: CircularProgressIndicator(),
              )),
        if (!isLoading && restaurantList.isEmpty)
          const Align(
            alignment: Alignment.center,
            child: Text("検索結果はありません"),
          ),
        for (var shop in restaurantList)
          Card(
            //影付きの角丸四角形
            elevation: 0, //影を消す
            color: AppColors.whiteColor,
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
              onTap: () {
                Navigator.pop(context, shop);
              },
            ),
          ),
      ],
    );
  }
}

class RegisteredTabPage extends StatelessWidget {
  final List<Shop> shopList;

  const RegisteredTabPage({Key? key, required this.shopList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (shopList.isEmpty)
          const Align(
            alignment: Alignment.center,
            child: Text("検索結果はありません"),
          ),
        for (var shop in shopList)
          Card(
            //影付きの角丸四角形
            elevation: 0, //影を消す
            color: AppColors.whiteColor,
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
      ],
    );
  }
}
