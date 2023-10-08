import 'package:flutter/material.dart';
import 'package:gohan_map/main.dart';

const tabTitle = <TabItem, String>{
  TabItem.map: 'マップ',
  TabItem.allpost: '投稿一覧',
  TabItem.character: '育成',
};
const tabIcon = <TabItem, IconData>{
  TabItem.map: Icons.map,
  TabItem.allpost: Icons.list,
  TabItem.character: Icons.mood,
};

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onSelect,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        bottomItem(
          context,
          tabItem: TabItem.map,
        ),
        bottomItem(
          context,
          tabItem: TabItem.allpost,
        ),
        bottomItem(
          context,
          tabItem: TabItem.character,
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      onTap: (index) {
        onSelect(TabItem.values[index]);
      },
    );
  }

  BottomNavigationBarItem bottomItem(
    BuildContext context, {
    required TabItem tabItem,
  }) {
    final color = currentTab == tabItem ? Colors.blue : Colors.black26;
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(
            tabIcon[tabItem],
            color: color,
          ),
          Text(tabTitle[tabItem] ?? '',
              style: TextStyle(
                color: color,
                fontSize: 12,
              )),
        ],
      ),
      label: '',
    );
  }
}
