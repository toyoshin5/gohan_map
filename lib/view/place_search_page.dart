import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/icon/app_icon_icons.dart';
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

  List<RestaurantResult> restaurants = [
    RestaurantResult(
        apiResult: PlaceApiRestaurantResult(
            latlng: LatLng(0, 0),
            name: "サイゼリヤサイゼリヤサイゼリヤサイゼリヤサイゼリヤ",
            placeId: "test",
            address: "札幌市北区北２条東1丁目サンプルサンプルサンプルサンプル"),
        isRegistered: false,
      ) 
  ];
  late TabController tabController;
  bool filterRegistered = false; // 0: マップ付近の飲食店, 1: 登録済み

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
              onPressClear: () {
                setState(() {
                  searchText = "";
                });
              },
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
              height: 20,
            ),

            RegisteredFilterButton(onChanged: (value) {
              setState(() {
                filterRegistered = value;
              });
            }),

            const SizedBox(
              height: 20,
            ),

            // マップ付近の飲食店
            SearchResultArea(
                restaurantList: restaurants,
                isLoading: isLoadingPlaceApi,
                filterRegistered: filterRegistered),
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
      restaurants = [];
    });

    var apiResult = await searchRestaurantsByGoogleMapApi(
      searchText,
      LatLng(widget.mapController.center.latitude,
          widget.mapController.center.longitude),
    );

    List<RestaurantResult> restaurantTmp = [];
    for (var restaurant in apiResult) {
      var shop = await IsarUtils.getShopByGooglePlaceId(restaurant.placeId);
      if (shop != null) {
        restaurantTmp.add(RestaurantResult(apiResult: restaurant, isRegistered: true));
      } else {
        restaurantTmp.add(RestaurantResult(apiResult: restaurant, isRegistered: false));
      }
    }

    logger.d("API呼び出し");
    setState(() {
      isLoadingPlaceApi = false;
      restaurants = restaurantTmp;
    });

  }
}

class SearchResultArea extends StatelessWidget {
  final List<RestaurantResult> restaurantList;
  final bool isLoading;
  final bool filterRegistered;

  const SearchResultArea(
      {Key? key,
      required this.restaurantList,
      required this.isLoading,
      this.filterRegistered = false})
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
        if (!filterRegistered || shop.isRegistered)...[
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: InkWell(
              onTap: () async {
                if (shop.isRegistered){
                  //idを返す
                  Shop? s = await IsarUtils.getShopByGooglePlaceId(shop.apiResult.placeId);
                  if (s != null && context.mounted) {
                    Navigator.pop(context, s.id);
                  }
                }else{
                  //ApiResultを返す
                  if (context.mounted) {
                    Navigator.pop(context, shop.apiResult);
                  }
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    children: [
                      //アイコン
                      SizedBox(
                        //角丸四角形
                        width: 30,
                        height: 34,
                        child: Icon(
                          AppIcons.map_marker_alt,
                          size: 28,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        "1.0km",
                        style: TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          shop.apiResult.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          shop.apiResult.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.greyDarkColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _RegisterBudge(isRegistered: shop.isRegistered),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1,thickness: 1,),
        ],
      ],
    );
  }
}

//登録済みボタン
class RegisteredFilterButton extends StatefulWidget {
  const RegisteredFilterButton({
    super.key,
    this.initialIsUmai,
    required this.onChanged,
  });

  final bool? initialIsUmai;
  final Function(bool) onChanged;

  @override
  State<RegisteredFilterButton> createState() => _RegisteredFilterButtonState();
}

class _RegisteredFilterButtonState extends State<RegisteredFilterButton> {
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialIsUmai ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: (isOn)
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: (isOn) ? 3 : 0,
          backgroundColor:
              (isOn) ? AppColors.primaryColor : AppColors.whiteColor, //色
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color:
                  (isOn) ? AppColors.primaryColor : AppColors.greyDarkColor, //色
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          setState(() {
            isOn = !isOn;
            widget.onChanged(isOn);
          });
        },
        child: Container(
          //角丸四角形
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '# 登録済み',
                style: TextStyle(
                  color:
                      (isOn) ? AppColors.whiteColor : AppColors.greyDarkColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//登録可否バッジ
class _RegisterBudge extends StatelessWidget {
  final bool isRegistered;
  const _RegisterBudge({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: (isRegistered) ? AppColors.redTextColor : AppColors.greyColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (isRegistered) ? 8 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRegistered)
              const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.whiteColor,
              ),
            Text(
              (isRegistered) ? '登録済み' : '未登録',
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//検索結果
class RestaurantResult {
  late PlaceApiRestaurantResult apiResult;
  late bool isRegistered;
  RestaurantResult({required this.apiResult, required this.isRegistered});
}
