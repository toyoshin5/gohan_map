import 'dart:ui';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/colors/app_colors.dart';

///下から出てくるモーダルウィジェットの中身の雛形
class AppModal extends StatelessWidget {
  final Widget child; //子要素となるウィジェット
  final double initialChildSize; //初期の大きさが画面の高さの何倍か
  final double minChildSize; //最小の大きさが画面の高さの何倍か (最大の大きさはNavigationBarの下までで固定)
  final double maxChildSize; //最大の大きさが画面の高さの何倍か
  final bool showKnob; //つまみを表示するか
  const AppModal({
    this.initialChildSize = 0.4,
    this.minChildSize = 0.2,
    this.maxChildSize = 0,
    this.showKnob = true,
    required this.child,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //modalの高さをNavigationBarに合わせる
    var ratio = 0.0;
    var displayHeight = MediaQuery.of(context).size.height;
    var navigationBarHeight =
        AppBar().preferredSize.height + 22; //22はstatusBarの高さ
    if (maxChildSize == 0) {
      ratio = (displayHeight - navigationBarHeight) / displayHeight;
    }else{
      ratio = maxChildSize;
    }
    return GestureDetector(//モーダルの外側をタップしたらモーダルを閉じる
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: DraggableScrollableSheet(//スクロール可能なモーダルウィジェット
        builder: (BuildContext context, scrollController) {
          return Container(//モーダルの中身
            decoration: BoxDecoration(
              color: AppColors.backgroundModalColor,
              border: Border.all(
                color: AppColors.backgroundGrayColor,
                width: 1,),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: ClipRRect(//ぼかす領域を指定するためのウィジェット
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: BackdropFilter(//ぼかすためのウィジェット
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: SingleChildScrollView(
                  //DraggableScrollableSheeの子要素は必ずScrollableなウィジェットである必要がある
                  controller: scrollController,
                  child: Column(
                    children: [
                      if (showKnob)
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                          height: 5,
                          width: 26,
                          decoration: BoxDecoration(
                            color: const Color(0x16000000),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        initialChildSize: initialChildSize /*最初の大きさが親ウェジェットの何倍か*/,
        minChildSize: minChildSize /*最小の大きさが親ウェジェットの何倍か*/,
        maxChildSize: ratio /*最大の大きさが親ウェジェットの何倍か*/,
      ),
    );
  }
}
