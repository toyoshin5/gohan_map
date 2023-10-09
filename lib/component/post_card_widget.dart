//1投稿分のカード
import 'dart:io';
import 'dart:math';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/app_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:path/path.dart' as p;

class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    super.key,
    required this.timeline,
    required this.imageData,
    required this.onEditTapped,
    required this.onDeleteTapped,
  });

  final Timeline timeline;
  final String imageData;
  final VoidCallback onEditTapped;
  final VoidCallback onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                      DateFormat('yyyy')
                                          .format(timeline.date),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black,height: 1.5),
                                    ),
                              const SizedBox(width: 2),
                              Text(
                                      DateFormat('MM/dd')
                                          .format(timeline.date),
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black,height: 1.0),
                                    ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8, left: 2),
                                child: Row(children: [
                                  Text(
                                    timeline.star.toString(),
                                    style: const TextStyle(color: Colors.black38),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                  ),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: AppRatingBar(
                                      initialRating: timeline.star,
                                      onRatingUpdate: (rating) {},
                                      itemSize: 20,
                                    ),
                                  )
                                ]),
                              ),
                            ],
                          ),
                          PullDownButton(
                            itemBuilder: (context) => [
                              PullDownMenuItem(
                                onTap: onEditTapped,
                                title: '編集',
                                icon: CupertinoIcons.pencil,
                              ),
                              PullDownMenuItem(
                                onTap: onDeleteTapped,
                                title: '削除',
                                isDestructive: true,
                                icon: CupertinoIcons.delete,
                              ),
                            ],
                            animationBuilder: null,
                            position: PullDownMenuPosition.automatic,
                            buttonBuilder: (_, showMenu) => CupertinoButton(
                              onPressed: showMenu,
                              padding: EdgeInsets.zero,
                              pressedOpacity: 1,
                              child: const Icon(
                                CupertinoIcons.ellipsis,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (timeline.image != null && timeline.image!.isNotEmpty)
          //縦長の場合は正方形にする
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: min(MediaQuery.of(context).size.width, 400)
              ),
              child: Image.file(
                        File(p.join(imageData, timeline.image!)),
                        fit: BoxFit.contain,
                      ),
            ),
          ),
        if (timeline.comment != "")
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                timeline.comment,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          )
        else
          const SizedBox(height: 16,),
      ]),
    );
  }
}
