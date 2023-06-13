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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gohan Map',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        //appBar: AppBar(
        //  title: const Text('Gohan Map'),
        //),
        body: MapPage(),
      ),
    );
  }
}
