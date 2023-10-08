import 'package:flutter/Material.dart';
import 'package:gohan_map/main.dart';
import 'package:gohan_map/view/all_post_page.dart';
import 'package:gohan_map/view/character_page.dart';
import 'package:gohan_map/view/map_page.dart';

//現在のタブによって、Navigatorを切り替えるためのクラス
//これを使うことで、タブの内部で画面遷移ができる
class TabNavigator extends StatelessWidget {
  const TabNavigator({
    Key? key,
    required this.tabItem,
    required this.routerName,
    required this.navigationKey,
  }) : super(key: key);

  final TabItem tabItem;
  final String routerName;
  final GlobalKey<NavigatorState> navigationKey;

  Map<String, Widget Function(BuildContext)> _routerBuilder(BuildContext context) => {
    '/map': (context) => const MapPage(),
    '/allpost': (context) => const AllPostPage(),
    '/character': (context) => const CharacterPage(),
  };

  @override
  Widget build(BuildContext context) {
    final routerBuilder = _routerBuilder(context);

    return Navigator(
      key: navigationKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute<Widget>(
          builder: (context) {
            return routerBuilder[routerName]!(context);
          },
        );
      },
    );
  }
}
