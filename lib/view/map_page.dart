import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/view/place_create_page.dart';

class MapPage extends StatelessWidget {
  // StatelessWidgetは、状態を持たないウィジェット。情報が変わらないウィジェット。
  const MapPage({Key? key})
      : super(
            key: key); // Key? keyは、ウィジェットの識別子。ウィジェットの状態を保持するためには必要だが、今回は特に使わない。

  @override
  Widget build(BuildContext context) {
    // buildメソッドは、ウィジェットを構築するメソッド。画面が表示されるときに呼ばれる。
    return Column(
      //縦に並べる
      mainAxisAlignment: MainAxisAlignment.start, //上寄せ
      children: [
        const Text('Gohan Map'),
        CupertinoButton(
          child: const Text('Create'),
          onPressed: () {
            showModalBottomSheet(
              barrierColor: Colors.black.withOpacity(0.05),
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return const PlaceCreatePage();
              },
            );
          },
        ),
      ],
    );
  }
}
