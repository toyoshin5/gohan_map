
import 'package:flutter/material.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

import '../component/app_search_bar.dart';

class PlaceSearchPage extends StatefulWidget {
  //StatefulWidgetは状態を持つWidget。検索結果を表示するために必要。
  const PlaceSearchPage({Key? key}) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  var isSearch = false;
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
              onSubmitted: (text) {
                setState(() {
                  isSearch = true;
                });
              },
            ),
            const SizedBox(
              height: 16,
            ),
            for (var i = 0; i < 20; i++)
              if (isSearch)
                Card(
                  //影付きの角丸四角形
                  elevation: 0, //影を消す
                  color: AppColors.backgroundWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), //角丸の大きさ
                  ),
                  child: ListTile(
                    title: Text('place$i'),
                    onTap: () {
                      Navigator.pop(context, "<searchid>");
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

