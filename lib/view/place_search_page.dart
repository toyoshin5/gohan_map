import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/utils/isar_utils.dart';

import '../component/app_search_bar.dart';

class PlaceSearchPage extends StatefulWidget {
  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  const PlaceSearchPage({Key? key}) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchText = "";
  List<Shop> shopList = [];

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
              },
            ),
            const SizedBox(
              height: 32,
            ),
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
                  titleTextStyle: const TextStyle(fontSize: 18, color: AppColors.blackTextColor, overflow: TextOverflow.ellipsis),
                  subtitle: Text(shop.shopAddress),
                  subtitleTextStyle: const TextStyle(overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context, shop.id);
                  },
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
}
