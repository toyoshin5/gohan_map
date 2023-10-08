import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gohan_map/bottom_navigation.dart';
import 'package:gohan_map/tab_navigator.dart';
import 'package:gohan_map/utils/logger.dart';
import 'package:gohan_map/utils/safearea_utils.dart';

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

enum TabItem {
  map,
  allpost,
  character,
}

//タブバー(BottomNavigationBar)を含んだ全体の画面
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TabItem _currentTab = TabItem.map;
  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.map: GlobalKey<NavigatorState>(),
    TabItem.allpost: GlobalKey<NavigatorState>(),
    TabItem.character: GlobalKey<NavigatorState>(),
  };

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildTabItem(
            TabItem.map,
            '/map',
          ),
          _buildTabItem(
            TabItem.allpost,
            '/allpost',
          ),
          _buildTabItem(
            TabItem.character,
            '/character',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentTab: _currentTab,
        onSelect: onSelect,
      ),
    );
  }

  Widget _buildTabItem(
    TabItem tabItem,
    String root,
  ) {
    return Offstage(//Offstageは、子要素を非表示にするウィジェット
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigationKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
        routerName: root,
      ),
    );
  }

  //タブが選択されたときに呼ばれる。tabItemは選択されたタブ
  void onSelect(TabItem tabItem) {
    //選択されたタブが現在のタブと同じなら、そのタブの最初の画面に戻る
    if (_currentTab == tabItem) {
      _navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentTab = tabItem;
      });
    }
  }

}
