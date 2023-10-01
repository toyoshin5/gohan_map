import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gohan_map/utils/logger.dart';
import 'package:gohan_map/utils/safearea_utils.dart';
import 'package:gohan_map/view/map_page.dart';

/// アプリが起動したときに呼ばれる
void main() {
  logger.i("start application!");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  // スプラッシュ画面をロードが終わるまで表示する
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

///アプリケーションの最上位のウィジェット
///ウィジェットとは、画面に表示される要素のこと。
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //セーフエリア外の高さを保存しておく
    SafeAreaUtil.unSafeAreaBottomHeight = MediaQuery.of(context).padding.bottom;
    SafeAreaUtil.unSafeAreaTopHeight = MediaQuery.of(context).padding.top;
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
