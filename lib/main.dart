import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/view/map_page.dart';

/// アプリが起動したときに呼ばれる
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

///アプリケーションの最上位のウィジェット
///ウィジェットとは、画面に表示される要素のこと。
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Gohan Map',
      //ステータスバーの文字を消す
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,//キーボードが出てきたときに画面を上にずらすかどうか
        //Scaffoldは画面の枠組みを作るウィジェット。基本的アプリに1つで、画面全体を覆う最上位ウィジェットであることを示す。
        // navigationBar: const CupertinoNavigationBar(
        //   //上のバー
        //   middle: Text('Gohan Map'), //上のバーの中央に表示される文字
        // ),
        child: MapPage(),
      ),
      localizationsDelegates: [
              DefaultMaterialLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
    );
  }
}
