import 'dart:ui';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_search_bar.dart';
import 'package:gohan_map/view/place_create_page.dart';
import 'package:gohan_map/view/place_detail_page.dart';
import 'package:gohan_map/view/place_search_page.dart';

///地図が表示されている画面
class MapPage extends StatelessWidget {
  // StatelessWidgetは、状態を持たないウィジェット。情報が変わらないウィジェット。
  const MapPage({Key? key})
      : super(
            key: key); // Key? keyは、ウィジェットの識別子。ウィジェットの状態を保持するためには必要だが、今回は特に使わない。

  @override
  Widget build(BuildContext context) {
    // buildメソッドは、ウィジェットを構築するメソッド。画面が表示されるときに呼ばれる。
    return Stack(
      children: [
        //MAPの画像(ダミー)表示
        Image.asset(
          'images/dummyMap.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: Column(
            //縦に並べる
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('MapPage'),
              CupertinoButton(
                //iOS風のボタン
                child: const Text('Create'),
                onPressed: () {
                  showModalBottomSheet(
                    //モーダルを表示する関数
                    barrierColor: Colors.black.withOpacity(0),
                    isDismissible: true,
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return const PlaceCreatePage(); //飲食店を作成する画面
                    },
                  );
                },
              ),
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
        Align(
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
        ),
      ],
    );
  }
}
