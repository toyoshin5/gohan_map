//1投稿分のカード
import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:path/path.dart' as p;

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.timeline,
    required this.selectedShop,
    required this.snapshot,
    required this.onEditTapped,
    required this.onDeleteTapped,
  });

  final Timeline timeline;
  final Shop? selectedShop;
  final AsyncSnapshot<String> snapshot;
  final VoidCallback onEditTapped;
  final VoidCallback onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.access_time,
                                  size: 18,
                                ),
                              ),
                              // アイコンとテキストの間のスペースを設定
                              Text(
                                DateFormat('yyyy/MM/dd')
                                    .format(timeline.date),
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black38),
                              ),
                              if (timeline.umai)
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12),
                                  child: Icon(
                                    Icons.thumb_up,
                                    size: 18,
                                    color: Color(0xFF2196F3),
                                  ),
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
                            position: PullDownMenuPosition
                                .automatic,
                            buttonBuilder: (_, showMenu) =>
                                CupertinoButton(
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
                      if (timeline.comment != "")
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8),
                          child: Text(
                            timeline.comment,
                            style:
                                const TextStyle(fontSize: 15),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),),
      if (timeline.image != null &&
          timeline.image!.isNotEmpty)
        Image.file(
          File(p.join(snapshot.data!, timeline.image!)),
          fit: BoxFit.fitWidth,
        )
    ]);
  }
}
