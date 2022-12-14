import 'package:flutter/Cupertino.dart';
import 'package:gohan_map/component/app_modal.dart';
/// 飲食店でのごはん投稿画面
class PlacePostPage extends StatelessWidget {
  const PlacePostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.5,
      child: Padding(//余白を作るためのウィジェット
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(//縦に並べるためのウィジェット
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlacePostPage'),
            CupertinoButton(
              child: const Text('Post'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),  
      ),
    );
  }
}


