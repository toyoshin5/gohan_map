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
      height: 600,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceSearchPage'),
              Container(
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoButton(
                        child: const Text('SearchButton'),
                        onPressed: () {
                          setState(() {
                            isSearch = true;
                          });
                        },
                      ),
                      for (var i = 0; i < 20; i++)
                        if (isSearch)
                        Card(
                          child: ListTile(
                            title: Text('place$i'),
                            onTap: () {
                              Navigator.pop(context,"searchid");
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
