import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gohan_map/utils/logger.dart';
import 'package:gohan_map/utils/safearea_utils.dart';
import 'package:gohan_map/view/all_post_page.dart';
import 'package:gohan_map/view/character_page.dart';
import 'package:gohan_map/view/map_page.dart';

/// アプリが起動したときに呼ばれる
void main() {
  logger.i("start application!");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
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
        body: MainPage(),
      ),
    );
  }
}


//タブ(BottomNavigationBar)を含んだ画面
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final items = <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: "マップ",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: "投稿一覧",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mood),
      label: "育成",
    ),
  ];
  final tabs = <Widget>[
    const MapPage(),
    const AllPostPage(),
    const CharacterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
        ],
      ),
      bottomNavigationBar: _buildBttomNavigator(context),
    );
  }

  Widget _buildBttomNavigator(BuildContext context) {
    return BottomNavigationBar(
      items: items,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
    );
  }
}
