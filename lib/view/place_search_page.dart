
import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/component/gohan_app_modal.dart';

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
    return GohanAppModal(
      initialChildSize: 0.6,
      child: Padding(//余白を作るためのウィジェット
        padding: const EdgeInsets.symmetric(horizontal: 16),//左右に16pxの余白を作る
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceSearchPage'),
            CupertinoButton(//iOS風のボタン
              child: const Text('SearchButton'),
              onPressed: () {
                setState(() {
                  isSearch = true;
                });
              },
            ),
            for (var i = 0; i < 20; i++)
              if (isSearch)
                Card(//影付きの角丸四角形
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
