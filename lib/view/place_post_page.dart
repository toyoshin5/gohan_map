import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/component/gohan_app_modal.dart';

class PlacePostPage extends StatelessWidget {
  const PlacePostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GohanAppModal(
      height: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceCreatePage'),
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


