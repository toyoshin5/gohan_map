import 'package:flutter/Cupertino.dart';
import 'package:gohan_map/component/gohan_app_modal.dart';
///飲食店の登録画面
class PlaceCreatePage extends StatelessWidget {
  const PlaceCreatePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GohanAppModal(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceCreatePage'),
            CupertinoButton(
              child: const Text('Create'),
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


