import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/component/gohan_app_modal.dart';
import 'package:gohan_map/view/place_post_page.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GohanAppModal(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceDetailPage'),
            CupertinoButton(
              child: const Text('Post'),
              onPressed: () {
                showModalBottomSheet(
                  barrierColor: Colors.black.withOpacity(0),
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return const PlacePostPage();
                  },
                );
              },
            ),
            CupertinoButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoButton(
              child: const Text('Close'),
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


